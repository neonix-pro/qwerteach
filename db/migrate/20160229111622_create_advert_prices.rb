class CreateAdvertPrices < ActiveRecord::Migration
  def change
    create_table :advert_prices do |t|
      t.integer :advert_id, :null => false
      t.integer :level_id, :null => false
      t.decimal :price, :precision => 8, :scale => 2, :null => false, :default => 0
      t.timestamps null: false
    end
  end
end
