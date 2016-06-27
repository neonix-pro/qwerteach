class AddFeaturedAndPictoToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :featured, :boolean, :default => false
    add_column :topics, :picto, :string
    add_column :topic_groups, :featured, :boolean, :default => false
    add_column :topic_groups, :picto, :string
  end
end
