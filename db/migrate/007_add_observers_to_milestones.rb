class AddObserversToMilestones < ActiveRecord::Migration
  def self.up
    add_column :milestones, :observers, :string
  end

  def self.down
    remove_column :milestones, :observers
  end
end
