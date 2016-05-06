class CreateTopicGroups < ActiveRecord::Migration
  def change
    create_table :topic_groups do |t|
      t.string :title, null: false
      t.string :level_code, null: false
      t.timestamps null: false
    end
  end
end
