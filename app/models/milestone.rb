class Milestone < ActiveRecord::Base
  include Redmine::SafeAttributes
  class MilestoneInternalHelper
    include ActionView::Helpers::DateHelper
  end
  unloadable

  MILESTONE_KINDS = %w(internal aggregate)
  MILESTONE_STATUSES = %w(open closed locked)
  MILESTONE_SHARINGS = %w(none descendants hierarchy tree system specific)

  validates_inclusion_of :sharing, :in => MILESTONE_SHARINGS

  belongs_to :project
  belongs_to :user
  belongs_to :version
  belongs_to :parent_milestone, :class_name => 'Milestone', :foreign_key => :parent_milestone_id
  has_many :issues
  has_many :children, :class_name => 'Milestone', :foreign_key => :parent_milestone_id

  belongs_to :previous_start_date_milestone, :class_name => 'Milestone', :foreign_key => :previous_start_date_milestone_id
  belongs_to :previous_planned_end_date_milestone, :class_name => 'Milestone', :foreign_key => :previous_planned_end_date_milestone_id

  named_scope :opened, :conditions => {:status => %w(open locked)}
  named_scope :aggregate, :conditions => {:kind => 'aggregate'}
  named_scope :direct_children_of_version, lambda {|version| {:conditions=>["version_id = ? and (parent_milestone_id IS NULL or parent_milestone_id = 0) and kind='internal'", version.id], :order => 'start_date ASC'}}
  named_scope :internal, :conditions => {:kind => 'internal'}
  named_scope :orphaned, :conditions => ['parent_milestone_id IS NULL or parent_milestone_id = ?', 0]

  has_many :milestone_project_assignments

  accepts_nested_attributes_for :milestone_project_assignments, :allow_destroy => true

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
                  'previous_start_date_milestone_id'


  def self.active_for_version(version)
    version.milestones.select{|x| x.start_date.present? and x.planned_end_date.present? and x.start_date <= Date.today and x.planned_end_date >= Date.today}.first
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
    issues.count
  end

  def start_date
    if fixed_start_date
      read_attribute(:start_date)
    else
      start_date_offset.days.since(self.previous_start_date_milestone.planned_end_date)
    end
  end

  def planned_end_date
    if fixed_planned_end_date
      read_attribute(:planned_end_date)
    else
      planned_end_date_offset.days.since(self.previous_planned_end_date_milestone.planned_end_date)
    end

  end

  def issues_progress(open)
    @issues_progress ||= {}
    @issues_progress[open] ||= begin
      progress = 0
      if issues_count > 0
        ratio = open ? 'done_ratio' : 100

        done = issues.sum("COALESCE(estimated_hours, #{estimated_average}) * #{ratio}",
                                :joins => :status,
                                :conditions => ["#{IssueStatus.table_name}.is_closed = ?", !open]).to_f
        progress = done / (estimated_average * issues_count)
      end
      progress
    end
  end

  def estimated_average
    if @estimated_average.nil?
      average = issues.average(:estimated_hours).to_f
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

  def load_issue_counts
    unless @issue_count
      @open_issues_count = 0
      @closed_issues_count = 0
      issues.count(:all, :group => :status).each do |status, count|
        if status.is_closed?
          @closed_issues_count += count
        else
          @open_issues_count += count
        end
      end
      @issue_count = @open_issues_count + @closed_issues_count
    end
  end

  def actual_date
    (self.children.map(&:planned_end_date) + self.issues.map(&:due_date)).reject{|x| x.nil?}.max
  end

  def to_s
    self.name
  end

  def <=> (a)
    self.name <=> a.name
  end

  def level
    return 0 if self.parent_milestone.nil? and self.kind == "aggregate"
    return 1 if self.parent_milestone.nil? and self.kind == "internal"
    return parent_milestone.level + 1
  end

  def aggregate?
    self.kind == 'aggregate'
  end

  def orphaned?
    self.parent_milestone.nil?
  end

  def opened?
    %w(open locked).include? self.status
  end

  def composite_description
    ret = "#{name} #{closed_issues_count} #{I18n.t(:done)} (#{'%0.2f' % completed_pourcent}%) #{open_issues_count} #{I18n.t(:left)} (#{'%0.2f' % (100 - completed_pourcent)}%)"
    ret += " #{I18n.t(:owner)}: #{user.name}" if self.user.present?
    ret += " #{MilestoneInternalHelper.new.distance_of_time_in_words_to_now(self.planned_end_date)}" if self.planned_end_date.present?
    ret += " #{I18n.t(kind)}"
  end

end
