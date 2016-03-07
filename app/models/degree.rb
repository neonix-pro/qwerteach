class Degree < ActiveRecord::Base
  belongs_to :teacher, :foreign_key => :user_id, class_name: 'Teacher'
  belongs_to :level
  # Vérifie que l'année de réalisation est bien dans le passé
  validates_date :completion_year, :on_or_before => lambda { Date.current.year }
end
