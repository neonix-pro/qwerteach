class AddPaymentMethodToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_method, :integer, :default => 3
  end
end
