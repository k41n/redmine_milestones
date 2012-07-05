class MilestoneProjectAssignment < ActiveRecord::Base
  unloadable
  belongs_to :project
  belongs_to :milestone
end
