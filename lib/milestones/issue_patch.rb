require_dependency "issue"
module IssuePatch
  def self.included(base) # :nodoc:

    base.class_eval do
      belongs_to :milestone
      safe_attributes :milestone_id
    end

  end
end