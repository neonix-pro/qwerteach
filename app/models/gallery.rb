class Gallery < ActiveRecord::Base

  has_many :pictures, :dependent => :destroy
  belongs_to :user
  validates_uniqueness_of :user_id
end
