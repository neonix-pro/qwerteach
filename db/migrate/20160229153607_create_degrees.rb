class CreateDegrees < ActiveRecord::Migration
  def change
    create_table :degrees do |t|
      t.string :title
      t.string :institution
      t.integer :completion_year
      t.references :user, index: true, foreign_key: true
      t.references :level, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
