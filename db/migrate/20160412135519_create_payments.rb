class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :status, null: false, default: 0
      t.integer :payment_type, null: false, default: 0
      t.datetime :transfert_date, null: false, default: DateTime.now
      t.decimal :price, :precision => 8, :scale => 2, null: false
      t.integer :lesson_id, null: false
      t.integer :mangopay_payin_id
      t.datetime :execution_date
      t.timestamps null: false
    end
  end
end
