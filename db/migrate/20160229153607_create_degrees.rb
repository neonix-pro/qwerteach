class CreateDegrees < ActiveRecord::Migration
  def change
    create_table :degrees do |t|
      t.string :title, null: false
      t.string :institution, null: false
      t.integer :completion_year
      t.references :user, index: true, foreign_key: true, null: false
      t.references :level, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
