class AddTelephoneCountryCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone_country_code, :string
    rename_column :users, :phonenumber, :phone_number
  end
end
