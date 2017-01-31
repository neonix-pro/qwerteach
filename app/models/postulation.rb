class Postulation < ActiveRecord::Base

  belongs_to :teacher, :foreign_key => :user_id, class_name: 'Teacher'
  validates :user_id, presence: true
  validates_uniqueness_of :user_id

  def admin_fields
    {
      :interview =>self.interview_ok,
      :avatar=>self.avatar_ok,
      :general_informations=>self.gen_informations_ok,
      :offers=>self.offer_ok,
      :mangopay => mangopay,
      :email => email,
      :test_classe => test_classe
    }
  end

  def mangopay
    !self.teacher.mango_id.nil?
  end

  def email
    !self.teacher.confirmed_at.nil?
  end

  def test_classe
    #TODO: ajuster pour prendre en compte ttes les classes virtuelles
    !self.teacher.lessons_received.nil?
  end

  def dashboard_fields
    admin_fields
  end

  def ok_fields
    admin_fields.delete_if { |key, value| value==false }
  end

end
