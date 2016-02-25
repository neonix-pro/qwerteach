class Gallery < ActiveRecord::Base

  has_many :pictures, :dependent => :destroy
  belongs_to :user
  # Une seule Gallery par User
  validates_uniqueness_of :user_id
end
