class AddInfotoDiploma < ActiveRecord::Migration
  def change
    add_column :degrees, :adress, :string
    add_column :degrees, :postalCode, :integer
    add_column :degrees, :city, :string
    add_column :degrees, :country, :string
  end
end
