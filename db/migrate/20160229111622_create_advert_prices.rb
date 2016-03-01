class CreateAdvertPrices < ActiveRecord::Migration
  def change
    create_table :advert_prices do |t|
      t.integer :advert_id
      t.integer :level_id
      t.decimal :price, :precision => 8, :scale => 2
      t.timestamps null: false
    end
  end
end
