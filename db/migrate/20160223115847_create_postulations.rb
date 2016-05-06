class CreatePostulations < ActiveRecord::Migration
  def change
    create_table :postulations do |t|
      t.boolean :interview_ok, :default => false
      t.boolean :avatar_ok, :default => false
      t.boolean :gen_informations_ok, :default => false
      t.boolean :advert_ok, :default => false
      t.integer :user_id, null: false

      t.timestamps null: false
    end
  end
end
