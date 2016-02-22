class CreateLevels < ActiveRecord::Migration
/  def change
    create_table :levels do |t|

      t.timestamps null: false
      t.integer :code_niveau, null: false, :default => 1
      t.string :value, null: false, :default => "Primary school"

    end
  end/
  def up
    create_table :levels do |t|
      t.timestamps
      t.integer :level, null: false, :default => 1
      t.string :code, null: false
      t.string :be, null: false
      t.string :fr, null:false
      t.string :ch, null: false
    end
  end
  def down
    drop_table :levels
  end
end
