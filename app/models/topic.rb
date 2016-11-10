class Topic < ActiveRecord::Base

  belongs_to :topic_group
  has_many :adverts
  has_many :lessons

  validates :topic_group, presence: true
  validates :title, presence: true


  def pictotype(arg)
    if picto.nil?
      topic_group.pictotype(arg)
    else
      picto.insert(-5, "_#{arg}")
    end
  end

end
