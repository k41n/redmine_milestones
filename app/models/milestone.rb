class Milestone < ActiveRecord::Base
  include Redmine::SafeAttributes
  class MilestoneInternalHelper
    include ActionView::Helpers::DateHelper
  end
  unloadable

  MILESTONE_STATUSES = %w(open closed locked)
  MILESTONE_SHARINGS = %w(none descendants hierarchy tree system specific)

  validates_inclusion_of :sharing, :in => MILESTONE_SHARINGS

  belongs_to :project
  belongs_to :user
  belongs_to :version
  #belongs_to :parent_milestone, :class_name => 'Milestone', :foreign_key => :parent_milestone_id
  has_many :issues
  #has_many :children, :class_name => 'Milestone', :foreign_key => :parent_milestone_id

  belongs_to :previous_start_date_milestone, :class_name => 'Milestone', :foreign_key => :previous_start_date_milestone_id
  belongs_to :previous_planned_end_date_milestone, :class_name => 'Milestone', :foreign_key => :previous_planned_end_date_milestone_id

  named_scope :opened, :conditions => {:status => %w(open locked)}
  named_scope :direct_children_of_version, lambda {|version| {:conditions=>["version_id = ? and (parent_milestone_id IS NULL or parent_milestone_id = 0)", version.id], :order => 'start_date ASC'}}
  named_scope :orphaned, :conditions => ['parent_milestone_id IS NULL or parent_milestone_id = ?', 0]
  named_scope :versionless, :conditions => ['version_id IS NULL OR version_id = ?', 0]

  named_scope :for_project, lambda {|project| {:conditions => {:project_id => project.id}}}

  has_many :milestone_project_assignments
  has_many :projects, :through => :milestone_project_assignments

  has_many :parent_milestone_assignments, :class_name => 'MilestoneAssignment', :foreign_key => :parent_id
  has_many :children, :through => :parent_milestone_assignments, :as => :parent
  has_many :child_milestone_assignments, :class_name => 'MilestoneAssignment', :foreign_key => :child_id
  has_many :parents, :through => :child_milestone_assignments, :as => :child

  serialize :observers

  accepts_nested_attributes_for :milestone_project_assignments, :allow_destroy => true
  accepts_nested_attributes_for :parent_milestone_assignments, :allow_destroy => true
  accepts_nested_attributes_for :child_milestone_assignments, :allow_destroy => true

  safe_attributes 'name',
                  'description',
                  'kind',
                  'sharing',
                  'status',
                  'planned_end_date',
                  'start_date',
                  'actual_date',
                  'parent_milestone_id',
                  'user_id',
                  'version_id',
                  'subproject',
                  'milestone_project_assignments_attributes',
                  'fixed_planned_end_date',
                  'fixed_start_date',
                  'planned_end_date_offset',
                  'start_date_offset',
                  'previous_planned_end_date_milestone_id',
                  'previous_start_date_milestone_id',
                  'parent_milestone_assignments_attributes',
                  'child_milestone_assignments_attributes',
                  'assigned_projects',
                  'assigned_milestones',
                  'observers'


  def self.active_for_version(version)
    version.milestones.select{|x| x.start_date.present? and x.planned_end_date.present? and x.start_date <= Date.today and x.planned_end_date >= Date.today}.first
  end

  def ansectors(visited = [])
    visited << self.id
    visited << self.parents.reject{|x| visited.include? x.id}.collect{|x| x.ansectors} unless self.parents.empty?
    visited.flatten.uniq
  end

  def assigned_projects=(projects)
    self.projects = projects.collect{|x| Project.find(x)}
  end

  def assigned_milestones=(milestones)
    self.children = milestones.collect{|x| Milestone.find(x)}
  end

  # Returns the sharings that +user+ can set the version to
  def allowed_sharings(user = User.current)
    MILESTONE_SHARINGS.select do |s|
      if sharing == s
        true
      else
        case s
          when 'system'
            # Only admin users can set a systemwide sharing
            user.admin?
          when 'hierarchy', 'tree'
            # Only users allowed to manage versions of the root project can
            # set sharing to hierarchy or tree
            project.nil? || user.allowed_to?(:manage_versions, project.root)
          else
            true
        end
      end
    end
  end

  def subproject_id
    self.project.present? ? self.project.id : nil
  end

  def estimated_hours
    @estimated_hours ||= issues.sum(:estimated_hours).to_f
  end

  def closed_pourcent
    if issues_count == 0
      0
    else
      issues_progress(false)
    end
  end

  def issues_count
    all_issues.count
  end

  def start_date
    if fixed_start_date
      read_attribute(:start_date)
    else
      start_date_offset.days.since(self.previous_start_date_milestone.planned_end_date) unless self.previous_start_date_milestone.nil? or self.previous_start_date_milestone.planned_end_date.nil?
    end
  end

  def planned_end_date
    if fixed_planned_end_date
      read_attribute(:planned_end_date)
    else
      return nil if planned_end_date_offset.nil?
      unless self.previous_planned_end_date_milestone.nil? or self.previous_planned_end_date_milestone.planned_end_date.nil?
        return planned_end_date_offset.days.since(self.previous_planned_end_date_milestone.planned_end_date)
      else
        return planned_end_date_offset.days.since(self.previous_planned_end_date_milestone.actual_date) if self.previous_planned_end_date_milestone.actual_date
      end
    end
  end

  def next_milestone
    return nil if self.start_date.nil?
    available = self.project.milestones.select{|x| x.start_date.present? and x.start_date > self.start_date}
    if available.empty?
      nil
    else
      available.sort{|a,b| a.start_date <=> b.start_date}.first
    end
  end

  def previous_milestone
    return nil if self.start_date.nil?
    available = self.project.milestones.select{|x| x.start_date.present? and x.start_date < self.start_date}
    if available.empty?
      nil
    else
      available.sort{|a,b| a.start_date <=> b.start_date}.last
    end
  end

  def completed?
    self.status == 'closed'
  end

  def issues_progress(open)
    @issues_progress ||= {}
    @issues_progress[open] ||= begin
      progress = 0
      if issues_count > 0
        done = all_issues.select{|x| x.status.is_closed != open}.inject(0){ |sum,x| sum + (x.estimated_hours.present? ? x.estimated_hours : estimated_average) * (open ? x.done_ratio : 100)}
        #("COALESCE(estimated_hours, #{estimated_average}) * #{ratio}",
        #                        :joins => :status,
        #                        :conditions => ["#{IssueStatus.table_name}.is_closed = ?", !open]).to_f
        progress = done / (estimated_average * issues_count)
      end
      progress
    end
  end

  def estimated_average
    if @estimated_average.nil?
      meaning_issues = all_issues.select{|x| x.estimated_hours.present? }
      average = meaning_issues.size.zero? ? 0 : meaning_issues.inject(0){|sum,x| sum + x.estimated_hours}.to_f / meaning_issues.size
      if average == 0
        average = 1
      end
      @estimated_average = average
    end
    @estimated_average
  end

  def completed_pourcent
    if issues_count == 0
      0
    elsif open_issues_count == 0
      100
    else
      issues_progress(false) + issues_progress(true)
    end
  end

  def open_issues_count
    load_issue_counts
    @open_issues_count
  end

  def closed_issues_count
    load_issue_counts
    @closed_issues_count
  end

  def spent_hours
    @spent_hours ||= TimeEntry.sum(:hours, :joins => :issue, :conditions => ["#{Issue.table_name}.milestone_id = ?", id]).to_f
  end

  def all_issues(visited = [])
    visited << self.id
    issues + children.reject{ |x| visited.include? x.id }.collect{ |x| x.all_issues(visited) }.flatten
  end

  def load_issue_counts
    unless @issue_count
      @open_issues_count = 0
      @closed_issues_count = 0
      all_issues.group_by{ |x| x.status }.each do |status, group|
        if status.is_closed?
          @closed_issues_count += group.size
        else
          @open_issues_count += group.size
        end
      end
      @issue_count = @open_issues_count + @closed_issues_count
    end
  end

  def actual_date
    (self.children.map(&:effective_end_date) + self.issues.map(&:due_date)).reject{|x| x.nil?}.max
  end

  def effective_end_date
    issues_end_dates = self.issues.map(&:due_date).reject{|x| x.nil?}
    ret = issues_end_dates.empty? ? planned_end_date : issues_end_dates.max
    (actual_date.present? && actual_date > ret) ? actual_date : ret
  end

  def to_s
    self.name
  end

  def <=> (a)
    self.name <=> a.name
  end

  #def level
  #  return 0 if self.parent_milestone.nil? and self.kind == "aggregate"
  #  return 1 if self.parent_milestone.nil? and self.kind == "internal"
  #  return parent_milestone.level + 1
  #end

  def versionless?
    self.version.nil?
  end

  def orphaned?
    self.parents.empty?
  end

  def opened?
    %w(open locked).include? self.status
  end

  def composite_description
    ret = "\"#{name}\" #{closed_issues_count} #{I18n.t(:done)} (#{'%0.0f' % completed_pourcent}%) #{open_issues_count} #{I18n.t(:left)} (#{'%0.0f' % (100 - completed_pourcent)}%)"
    ret += " #{I18n.t(:owner)}: #{user.name}" if self.user.present?
    ret += " #{MilestoneInternalHelper.new.distance_of_time_in_words_to_now(self.planned_end_date)}" if self.planned_end_date.present?
    ret
  end

  def depending_from_this_start_date
    Milestone.find_all_by_previous_start_date_milestone_id_and_fixed_start_date(self.id, false)
  end

  def depending_from_this_planned_end_date
    Milestone.find_all_by_previous_planned_end_date_milestone_id_and_fixed_planned_end_date(self.id, false)
  end

  def watched_by?(user)
    logger.info self.observers
    not self.observers.nil? and self.observers.include? user.id.to_s
  end

  def actual_start_date
    (self.children.map(&:start_date) + self.issues.map(&:start_date)).reject{|x| x.nil?}.min
  end

  def observer_recipients
    return [] if self.observers.nil?
    self.observers.collect{|x| User.find(x).mail}
  end

  def cssclass
    return "yellow" if not self.planned_end_date.nil? and not self.actual_date.nil? and self.planned_end_date == self.actual_date
    return "rose" if not self.planned_end_date.nil? and not self.actual_date.nil? and self.planned_end_date < self.actual_date
  end

  def break_shared_assignments
    self.parents.each do |parent|
      if parent.project.id != self.project.id and not parent.project.shared_milestones.map(&:id).include? self.id
        parent.children.delete(self)
      end
    end
  end

end
