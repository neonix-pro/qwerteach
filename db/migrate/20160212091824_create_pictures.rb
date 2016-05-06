class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :description
      t.string :image
      t.integer :gallery_id, null: false
      t.string :gallery_token

      t.timestamps
    end
  end
end
