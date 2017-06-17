class AddVideoUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :video_url, :string, default: nil
  end
end
