class CreateGalleries < ActiveRecord::Migration
  def change
    create_table :galleries do |t|
      t.string :name
      t.string :description
      t.integer :cover
      t.string :token
      t.integer :user_id

      t.timestamps
    end
  end
end
