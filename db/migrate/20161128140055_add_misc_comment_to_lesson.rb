class AddMiscCommentToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :comment, :text
  end
end
