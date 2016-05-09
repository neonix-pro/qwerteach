class Degree < ActiveRecord::Base
  belongs_to :teacher, :foreign_key => :user_id, class_name: 'Teacher'
  belongs_to :level
  # Vérifie que l'année de réalisation est bien dans le passé
  #validates_date :completion_year, :on_or_before => lambda { Date.current.year }
  validates :completion_year, numericality: {only_integer: true, less_than_or_equal_to: Date.current.year}
  validates :user_id, presence: true
  validates :level_id, presence: true
  validates :title, presence: true
  validates :institution, presence: true

end
