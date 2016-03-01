class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :title
      t.integer :topic_group_id
      t.timestamps null: false
    end
  end
end
