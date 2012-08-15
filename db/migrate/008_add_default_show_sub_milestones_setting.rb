class AddDefaultShowSubMilestonesSetting < ActiveRecord::Migration
  def self.up
    MilestonesSettings.create(:key => "default_show_sub_milestones", :value => "false")
  end

  def self.down
    MilestonesSettings.find_by_key("default_show_sub_milestones").delete
  end
end
