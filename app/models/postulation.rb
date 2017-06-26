class Postulation < ActiveRecord::Base

  belongs_to :teacher, :foreign_key => :user_id, class_name: 'Teacher'
  belongs_to :responsible_admin, class_name: 'User', :foreign_key => :admin_id
  acts_as_commentable :private

  validates :user_id, presence: true
  validates_uniqueness_of :user_id

  def admin_fields
    {
      avatar: avatar_ok,
      general_informations: gen_informations_ok,
      offers: offer_ok,
      mangopay: mangopay,
      email: email,
      test_classe: test_classe,
      interview: interview_ok
    }
  end
  alias dashboard_fields admin_fields

  def mangopay
    teacher.mango_id.present?
  end

  def email
    teacher.confirmed_at.present?
  end

  def test_classe
    teacher.bbb_meetings.count > 0
  end

  def ok_fields
    admin_fields.delete_if { |_, value| !value }
  end

  def correction_text
    corrections_needed.map do |key|
      case key
        when :mangopay then I18n.t('admin.teacher.postulation.corrections.mangopay')
        when :email then I18n.t('admin.teacher.postulation.corrections.email')
        when :test_classe then I18n.t('admin.teacher.postulation.corrections.bbb')
        when :offers then I18n.t('admin.teacher.postulation.corrections.offers')
        when :general_informations then I18n.t('admin.teacher.postulation.corrections.description')
        when :avatar then I18n.t('admin.teacher.postulation.corrections.avatar')
        when :interview then I18n.t('admin.teacher.postulation.corrections.interview')
      end
    end.map{|msg| "\r- #{msg}"}.join
  end

  def corrections_needed
    admin_fields.select{|k,v| !v}.keys
  end

  def completed?
    corrections_needed.blank?
  end
end
