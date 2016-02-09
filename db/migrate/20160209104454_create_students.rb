class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|

      t.timestamps null: false
      t.integer :user_id, null:false
      t.integer :level, null: false, default: 1
      t.boolean :is_prof, null: false, default: false

    end
  end
end
