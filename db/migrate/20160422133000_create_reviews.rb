class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :sender
      t.references :subject
      t.text :review_text
      t.integer :note
      t.timestamps null: false
    end
  end
end
