class CreateDisputes < ActiveRecord::Migration
  def change
    create_table :disputes do |t|

      t.integer :status, default: 0
      t.belongs_to :user
      t.belongs_to :lesson

      t.timestamps null: false
    end
  end
end
