class CreateMilestonesSettings < ActiveRecord::Migration
  def self.up
    create_table :milestones_settings do |t|
      t.string :key
      t.string :value, :default => "false"
      t.references :project
    end
    MilestonesSettings.create(:key => "default_show_milestones", :value => "false")
    MilestonesSettings.create(:key => "default_show_closed_milestones", :value => "false")
  end

  def self.down
    drop_table :milestones_settings
  end
end
