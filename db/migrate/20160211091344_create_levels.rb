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
      t.integer :level_code, null: false, :default => 1
      t.string :value, null: false, :default => "Primary school"
    end
    Level.create_translation_table! :value => :string
  end
  def down
    drop_table :levels
    Level.drop_translation_table!
  end
end
