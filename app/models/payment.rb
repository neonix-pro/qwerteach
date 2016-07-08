class Payment < ActiveRecord::Base
  # 2 types de paiements : reservation et facture
  enum payment_type: [:prepayment, :postpayment]
  # meme nom que dans DB sinon KO.
  # cf schéma etats de Payment
  enum status: [:pending, :paid, :canceled, :blocked]
  belongs_to :lesson

  validates :status, presence: true
  validates :payment_type, presence: true
  validates :price, presence: true
  validates :price, :numericality => {:greater_than_or_equal_to => 0}
  validates :lesson_id, presence: true
  validates :transfert_date, presence: true

  def pending?
    status == 'pending'
  end

end
