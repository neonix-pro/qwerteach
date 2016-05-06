class CreateGalleries < ActiveRecord::Migration
  def change
    create_table :galleries do |t|
      t.integer :cover
      t.string :token
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
