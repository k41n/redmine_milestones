class Milestone < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable

  MILESTONE_KINDS = %w(internal aggregate)
  MILESTONE_STATUSES = %w(open closed locked)
  MILESTONE_SHARINGS = %w(none descendants hierarchy tree system)

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
  named_scope :internal, :conditions => {:kind => 'internal'}

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
                  'version_id'
                  'subproject'


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

end
