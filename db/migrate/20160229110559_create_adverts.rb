class CreateAdverts < ActiveRecord::Migration
  def change
    create_table :adverts do |t|
      t.integer :user_id
      t.integer :topic_id
      t.integer :topic_group_id
      t.string :other_name
      t.timestamps null: false
    end
  end
end
