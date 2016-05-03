class Payment < ActiveRecord::Base
  # 2 types de paiements : reservation et facture
  enum payment_type: [:prepayment, :postpayment]
  # meme nom que dans DB sinon KO.
  # cf schéma etats de Payment
  enum status: [:pending, :paid, :canceled, :blocked]
  belongs_to :lesson

end
