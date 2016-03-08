class CreateTopicGroups < ActiveRecord::Migration
  def change
    create_table :topic_groups do |t|
      t.string :title
      t.string :level_code
      t.timestamps null: false
    end
  end
end
