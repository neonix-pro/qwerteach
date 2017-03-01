class AddResponsibleAdminToPostulation < ActiveRecord::Migration
  def change
    add_column :postulations, :admin_id, :integer, default: nil
  end
end
