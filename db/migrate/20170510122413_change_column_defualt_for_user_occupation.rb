class ChangeColumnDefualtForUserOccupation < ActiveRecord::Migration
  def change
    change_column_default(:users, :occupation, '')
  end
end
