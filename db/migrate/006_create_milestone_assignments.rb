class CreateMilestoneAssignments < ActiveRecord::Migration
  def self.up
    create_table :milestone_assignments do |t|
      t.references :parent
      t.references :child
    end
  end

  def self.down
    drop_table :milestone_assignments
  end
end
