class AddRateTimeMsgUsers < ActiveRecord::Migration
  def change
    add_column :users, :response_rate, :integer, :default => 0
    add_column :users, :response_time, :integer, :default => 0
    add_column :users, :average_response_time , :integer, :default => 0
  end
end