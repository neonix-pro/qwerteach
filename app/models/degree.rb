class Degree < ActiveRecord::Base
  belongs_to :teacher, :foreign_key => :user_id, class_name: 'Teacher'
  belongs_to :level
end
