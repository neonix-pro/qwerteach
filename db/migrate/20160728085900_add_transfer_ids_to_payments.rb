class AddTransferIdsToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :transfer_eleve_id, :integer
    add_column :payments, :transfer_prof_id, :integer
  end
end
