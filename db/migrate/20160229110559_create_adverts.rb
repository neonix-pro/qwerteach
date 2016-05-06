class CreateAdverts < ActiveRecord::Migration
  def change
    create_table :adverts do |t|
      t.integer :user_id, null: false
      t.integer :topic_id, null: false
      t.integer :topic_group_id, null: false
      t.string :other_name
      t.timestamps null: false
    end
  end
end
