class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :sender, null: false
      t.references :subject, null: false
      t.text :comment_text, null: false
      t.timestamps null: false
    end
  end
end
