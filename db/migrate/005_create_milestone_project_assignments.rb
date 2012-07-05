class CreateMilestoneProjectAssignments < ActiveRecord::Migration
  def self.up
    create_table :milestone_project_assignments do |t|
      t.references :project
      t.references :milestone
    end
  end

  def self.down
    drop_table :milestone_project_assignments
  end
end
