class AddSmsPreferencesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sms_allowed, :boolean, default: true
  end
end
