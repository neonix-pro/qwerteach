class AddBonusTransactionFieldsToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :transfer_bonus_id, :integer
    add_column :payments, :transfer_bonus_amount, :float
  end
end
