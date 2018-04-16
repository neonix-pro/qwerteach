class AddRescheduledFieldToLessons < ActiveRecord::Migration
  def change
    add_column :lessons, :rescheduled, :integer, index: true, default: 0
  end
end
