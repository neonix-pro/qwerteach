class ChangeAdvertDescriptionToText < ActiveRecord::Migration
  def up
    change_column :adverts, :description,  :text
  end
  def down
    change_column :adverts, :description,  :string
  end
end
