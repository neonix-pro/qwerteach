class AddTransactionDetailsToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :transactions, :text
  end
end
