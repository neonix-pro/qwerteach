class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :title, null: false
      t.integer :topic_group_id, null: false
      t.timestamps null: false
    end
  end
end
