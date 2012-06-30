class CreateMilestones < ActiveRecord::Migration
  def self.up
    create_table :milestones do |t|
      t.string :name
      t.string :description
      t.integer :kind
      t.integer :sharing_model
      t.integer :status
      t.date :start_date
      t.date :planned_end_date
      t.date :actual_date
      t.integer :parent_id
      t.string :sharing
      t.references :project
      t.references :user
    end
  end

  def self.down
    drop_table :milestones
  end
end
