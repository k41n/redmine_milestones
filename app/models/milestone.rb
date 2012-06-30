class Milestone < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable

  MILESTONE_KINDS = %w(internal aggregate)
  MILESTONE_STATUSES = %w(open closed locked)
  MILESTONE_SHARINGS = %w(none descendants hierarchy tree system)

  validates_inclusion_of :sharing, :in => MILESTONE_SHARINGS

  belongs_to :project
  belongs_to :user
  belongs_to :parent_milestone, :class_name => 'Milestone', :foreign_key => :parent_id

  safe_attributes 'name',
                  'description',
                  'kind',
                  'sharing',
                  'status',
                  'planned_end_date',
                  'start_date',
                  'actual_date',
                  'parent_id',
                  'user_id'



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

end
