module Mango
  class PayinBancontact < ActiveInteraction::Base
    object :user, class: User

    integer :amount
    integer :fees, default: 0
    string :return_url

    validates :amount, :return_url, presence: true

    set_callback :execute, :before, :check_mango_account

    def execute
      payin = Mango.normalize_response MangoPay::PayIn::Card::Web.create(mango_params)
      if payin.status != 'CREATED'
        self.errors.add(:base, payin.result_message)
      end
      payin
    rescue MangoPay::ResponseError => error
      Rails.logger.debug(error)
      message = error.details['Message']
      message += error.details['errors'].map{|name, val| " #{name}: #{val} \n\n"}.join
      self.errors.add(:base, message)
    end

    private

    def check_mango_account
      raise Mango::UserDoesNotHaveAccount if user.mango_id.blank?
    end

    def beneficiary_wallet
      user.normal_wallet
    end

    def mango_params
      {
        :author_id => user.mango_id.to_s,
        :debited_funds => {
            :currency => "EUR",
            :amount => amount * 100
        },
        :fees => {
            :currency => "EUR",
            :amount => fees * 100
        },
        :credited_wallet_id => beneficiary_wallet.id,
        :ReturnURL => return_url,
        :culture => "FR",
        :card_type => "BCMC",
        :secure_mode => "FORCE"
      }.camelize_keys
    end

  end
end