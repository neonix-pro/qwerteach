class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.references :student, null: false
      t.references :teacher, null: false
      t.integer :status, null: false, default: 0
      t.datetime :time_start, null: false
      t.datetime :time_end, null: false
      t.integer :topic_id
      t.integer :topic_group_id, null: false
      t.integer :level_id, null: false
      t.decimal :price, :precision => 8, :scale => 2, null: false
      t.timestamps null: false
    end
  end
end
