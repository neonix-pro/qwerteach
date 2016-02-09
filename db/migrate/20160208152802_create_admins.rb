class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|

      t.timestamps null: false
      t.integer :user_id

    end
  end
end
