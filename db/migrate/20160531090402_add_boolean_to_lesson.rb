class AddBooleanToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :freeLesson, :boolean, :default => false
  end
end
