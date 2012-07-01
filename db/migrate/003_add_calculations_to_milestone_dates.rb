class AddCalculationsToMilestoneDates < ActiveRecord::Migration
  def self.up
    add_column :milestones, :fixed_planned_end_date, :boolean
    add_column :milestones, :fixed_start_date, :boolean
    add_column :milestones, :previous_start_date_milestone_id, :integer
    add_column :milestones, :previous_planned_end_date_milestone_id, :integer
    add_column :milestones, :planned_end_date_offset, :integer
    add_column :milestones, :start_date_offset, :integer
  end

  def self.down
    remove_column :milestones, :fixed_planned_end_date
    remove_column :milestones, :fixed_start_date
    remove_column :milestones, :previous_start_date_milestone_id
    remove_column :milestones, :previous_planned_end_date_milestone_id
    remove_column :milestones, :planned_end_date_offset
    remove_column :milestones, :start_date_offset
  end
end
