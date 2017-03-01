class Postulation < ActiveRecord::Base

  CORRECTION_MANGOPAY = "Prends le temps de configurer ton portefeuille virtuel. Nous avons besoin de tes coordonnées bancaires pour pouvoir te payer."
  CORRECTION_EMAIL = "L'email que tu as introduit n'a pas encore été validé. Nous t'avons envoyé un lien de confirmation par e-mail, clique dessus pour valider ton e-mail."
  CORRECTION_TEST_CLASSE = "Tu n'as pas encore essayé la classe virtuelle! Connecte-toi au moins une fois à la classe de démo afin de te familiariser avec l'outil."
  CORRECTION_OFFERS = "Veille à remplir convenablement tes annonces de cours. Nous utiliserons ces informations pour permettre aux élèves de te trouver et de réserver un cours avec toi."
  CORRECTION_GENERAL_INFORMATIONS = "Relis ta description. C'est sur base de ce texte que les élèves déideront de prendre ou non cours avec toi."
  CORRECTION_AVATAR = "Change ta photo de profil. Nous recommandons une photo de toi avec le visage bien visible."
  CORRECTION_INTERVIEW = "Avant d'approuver ta candidature, nous souhaitons réaliser un petit entretien vidéo avec toi. Pourrais-tu me communiquer 3 créneaux horaire quie te conviendraient, pour que nous puissions fixer rendez-vous?"

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
    logger.debug(corr)
    corr
  end

  def responsible_admin
    User.find(admin_id) unless admin_id.nil?
  end


end
