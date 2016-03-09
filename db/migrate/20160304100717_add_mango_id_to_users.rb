class AddMangoIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mango_id, :integer
  end
end
