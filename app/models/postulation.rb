class Postulation < ActiveRecord::Base

  CORRECTION_MANGOPAY = I18n.t('admin.teacher.postulation.corrections.mangopay')
  CORRECTION_EMAIL = I18n.t('admin.teacher.postulation.corrections.email')
  CORRECTION_TEST_CLASSE = I18n.t('admin.teacher.postulation.corrections.bbb')
  CORRECTION_OFFERS = I18n.t('admin.teacher.postulation.corrections.offers')
  CORRECTION_GENERAL_INFORMATIONS = I18n.t('admin.teacher.postulation.corrections.description')
  CORRECTION_AVATAR = I18n.t('admin.teacher.postulation.corrections.avatar')
  CORRECTION_INTERVIEW = I18n.t('admin.teacher.postulation.corrections.interview')

  CORRECTION_TEXT = {
      mangopay: CORRECTION_MANGOPAY,
      email: CORRECTION_EMAIL,
      test_classe: CORRECTION_TEST_CLASSE,
      offers: CORRECTION_OFFERS,
      general_informations: CORRECTION_GENERAL_INFORMATIONS,
      avatar: CORRECTION_AVATAR,
      interview: CORRECTION_INTERVIEW,
  }

  belongs_to :teacher, :foreign_key => :user_id, class_name: 'Teacher'
  attr_accessor :responsible_admin
  acts_as_commentable :private

  validates :user_id, presence: true
  validates_uniqueness_of :user_id

  def admin_fields
    {
      :avatar=>self.avatar_ok,
      :general_informations=>self.gen_informations_ok,
      :offers=>self.offer_ok,
      :mangopay => mangopay,
      :email => email,
      :test_classe => test_classe,
      :interview =>self.interview_ok
    }
  end

  def mangopay
    !self.teacher.mango_id.nil?
  end

  def email
    !self.teacher.confirmed_at.nil?
  end

  def test_classe
    teacher.bbb_meetings.count > 0
  end

  def dashboard_fields
    admin_fields
  end

  def ok_fields
    admin_fields.delete_if { |key, value| value==false }
  end

  def correction_text
    text = ''
    corrections_needed.each do |key|
      text += "\r- "
      text += CORRECTION_TEXT[key]
    end
    text
  end

  def corrections_needed
    corr = []
    admin_fields.each do |key, value|
      corr << key unless value
    end
    corr
  end

  def responsible_admin
    User.find(admin_id) unless admin_id.nil?
  end
end
