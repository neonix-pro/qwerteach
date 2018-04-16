class CreateLessonPackItems < ActiveRecord::Migration
  def change
    create_table :lesson_pack_items do |t|
      t.datetime :time_start
      t.integer :duration
      t.references :lesson_pack, index: true, foreign_key: true
    end
  end
end
