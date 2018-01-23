class AddSourceToUsers < ActiveRecord::Migration
  def change
    add_column(:users, :source, :string, null: true)
  end
end
