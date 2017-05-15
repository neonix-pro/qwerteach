class AddDescriptionToAdvert < ActiveRecord::Migration
  def change
    add_column :adverts, :description, :text
  end
end
