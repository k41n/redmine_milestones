module ProjectPatch
  def self.included(base) # :nodoc:

    base.class_eval do
      has_many :milestones, :class_name=>'Milestone', :foreign_key => :project_id
    end

  end
end