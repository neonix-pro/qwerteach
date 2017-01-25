class MakeTopicGroupNullable < ActiveRecord::Migration
  def change
    change_column :topics, :topic_group_id, :integer, :null => true
  end
end
