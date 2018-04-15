class CreateLessonPacks < ActiveRecord::Migration
  def change
    create_table :lesson_packs do |t|
      t.integer :status, default: 0
      t.references :topic, index: true
      t.references :level, index: true
      t.references :teacher, index: true
      t.references :student, index: true
      t.integer :discount

      t.timestamps null: false
    end
  end
end
