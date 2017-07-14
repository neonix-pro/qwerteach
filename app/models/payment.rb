class Payment < ActiveRecord::Base
  # 2 types de paiements : reservation et facture
  enum payment_type: [:prepayment, :postpayment]
  # meme nom que dans DB sinon KO.
  # cf schéma etats de Payment
  enum status: [:pending, :locked, :paid, :canceled, :disputed, :refunded]

  enum payment_method: [:creditcard, :bcmc, :wallet, :unknown]

  serialize :transactions, JSON
  #pending: en attente
  #paid: payé (au prof)
  #canceled: annulé
  #locked: détenu par Qwerteach
  #disputed: en litige
  #refunded: remboursé

  belongs_to :lesson

  validates :status, presence: true
  validates :payment_type, presence: true
  validates :price, presence: true
  validates :price, :numericality => {:greater_than_or_equal_to => 0}
  validates :lesson, presence: true
  validates :transfert_date, presence: true
  validates :payment_method, presence: true

  scope :locked, -> { where(status: [statuses[:locked], statuses[:disputed]]) }

end
