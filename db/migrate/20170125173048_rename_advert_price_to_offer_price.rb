class RenameAdvertPriceToOfferPrice < ActiveRecord::Migration
  def change
    rename_table :advert_prices, :offer_prices
    rename_table :adverts, :offers

    #rename_column :offer_prices, :advert_id, :offer_id
  end
end
