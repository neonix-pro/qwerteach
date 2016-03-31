class Postulation < ActiveRecord::Base

  belongs_to :teacher, :foreign_key => :user_id, class_name: 'Teacher'
end
