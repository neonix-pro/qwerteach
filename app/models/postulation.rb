class Postulation < ActiveRecord::Base

  belongs_to :teacher, :foreign_key => :user_id, class_name: 'Teacher'
  validates :user_id, presence: true
  validates_uniqueness_of :user_id

  def admin_fields
    {
      :interview =>self.interview_ok,
      :avatar=>self.avatar_ok,
      :general_informations=>self.gen_informations_ok,
      :adverts=>self.advert_ok,
      :mangopay => !self.teacher.mango_id.nil?,
      :email => !self.teacher.confirmed_at.nil?,
      :test_classe => !self.teacher.lessons_received.nil? #TODO: ajuster pour prendre en compte ttes les classes virtuelles
    }
  end

  def dashboard_fields
    admin_fields
  end

  def ok_fields
    admin_fields.delete_if { |key, value| value==false }
  end

end
