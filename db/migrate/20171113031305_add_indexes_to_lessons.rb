class AddIndexesToLessons < ActiveRecord::Migration
  def change
    add_index :lessons, :created_at
    add_index :lessons, :time_start
  end
end
