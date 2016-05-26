class AddIdToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :topics_id, :integer
  end
end
