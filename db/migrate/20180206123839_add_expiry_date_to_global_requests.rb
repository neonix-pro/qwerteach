class AddExpiryDateToGlobalRequests < ActiveRecord::Migration
  def change
    change_column :global_requests, :status, :integer, :default => 0
    add_column :global_requests, :expiry_date, :datetime
  end
end
