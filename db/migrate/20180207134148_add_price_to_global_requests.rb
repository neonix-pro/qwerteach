class AddPriceToGlobalRequests < ActiveRecord::Migration
  def change
    add_column :global_requests, :price_max, :integer
  end
end
