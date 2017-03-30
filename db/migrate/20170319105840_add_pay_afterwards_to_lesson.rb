class AddPayAfterwardsToLesson < ActiveRecord::Migration
  def change
    add_column :lessons, :pay_afterwards, :boolean, default: false, null: false
  end
end
