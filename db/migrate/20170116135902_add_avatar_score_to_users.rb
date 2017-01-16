class AddAvatarScoreToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar_score, :integer
  end
end
