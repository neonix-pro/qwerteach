class CreateInterests < ActiveRecord::Migration
  def change
    create_table :interests do |t|
      t.references :student, null: false
      t.references :topic, null: false

      t.timestamps null: false
    end
  end
end
