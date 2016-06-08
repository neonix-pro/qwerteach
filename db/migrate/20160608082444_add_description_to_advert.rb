class AddDescriptionToAdvert < ActiveRecord::Migration
  def change
    add_column :adverts, :description, :string, :default => ""
  end
end
