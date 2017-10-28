class CreateMasterclasses < ActiveRecord::Migration
  def change
    create_table :masterclasses do |t|
      t.integer :admin_id
      t.datetime :time_start

      t.timestamps null: false
    end
    add_column :bigbluebutton_rooms, :masterclass_id, :integer, :null => true
  end
end
