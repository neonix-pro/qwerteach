class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :status, null: false, default: Payment::STATUS_TYPE[0]
      t.integer :payment_type, null: false, default: "0"
      t.datetime :transfert_date
      t.integer :lesson_id, null: false
      t.integer :mangopay_payin_id
      t.datetime :execution_date
      t.timestamps null: false
    end
  end
end
