class Postulation < ActiveRecord::Base

  belongs_to :teacher, :foreign_key => :user_id, class_name: 'Teacher'
  validates :user_id, presence: true
  validates_uniqueness_of :user_id

end
