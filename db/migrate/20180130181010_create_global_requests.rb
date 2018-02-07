class CreateGlobalRequests < ActiveRecord::Migration
  def change
    create_table :global_requests do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :topic, index: true, foreign_key: true
      t.belongs_to :level, index: true, foreign_key: true
      t.text :description
      t.integer :status

      t.timestamps null: false
    end
  end
end
