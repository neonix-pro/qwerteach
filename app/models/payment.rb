class Payment < ActiveRecord::Base
  # 2 types de paiements : reservation et facture
  enum payment_type: [:prepayment, :postpayment]
  # meme nom que dans DB sinon KO.
  # cf schéma etats de Payment
  enum status: [:pending, :locked, :paid, :canceled, :disputed]

  enum payment_method: [:creditcard, :bcmc, :wallet, :unknown]
  #pending: en attente
  #paid: payé (au prof)
  #canceled: annulé
  #locked: détenu par Qwerteach
  #disputed: en litige

  belongs_to :lesson

  validates :status, presence: true
  validates :payment_type, presence: true
  validates :price, presence: true
  validates :price, :numericality => {:greater_than_or_equal_to => 0}
  validates :lesson_id, presence: true
  validates :transfert_date, presence: true
  validates :payment_method, presence: true

  def pending?
    status == 'pending'
  end
  def paid?
    status == 'paid'
  end
  def locked?
    status == 'locked'
  end
  def canceled?
    status == 'canceled'
  end
  def disputed?
    status == 'disputed'
  end
  def prepayment?
    payment_type == 'prepayment'
  end

  def postpayment?
    payment_type == 'postpayment'
  end

end
