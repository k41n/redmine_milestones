class MilestoneAssignment < ActiveRecord::Base
  unloadable

  belongs_to :parent, :class_name=>"Milestone", :foreign_key => :parent_id
  belongs_to :child, :class_name=>"Milestone", :foreign_key => :child_id
end
