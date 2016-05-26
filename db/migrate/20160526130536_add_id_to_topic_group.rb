class AddIdToTopicGroup < ActiveRecord::Migration
  def change
    add_column :topic_groups, :topic_group_id, :integer
  end
end
