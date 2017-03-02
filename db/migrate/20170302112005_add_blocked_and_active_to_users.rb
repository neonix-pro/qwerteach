class AddBlockedAndActiveToUsers < ActiveRecord::Migration
  def change
    add_column :users, :active, :boolean, default: true
    add_column :users, :blocked, :boolean, default: false
  end
end
