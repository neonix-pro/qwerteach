#Wrapper for user's mongopay data
class MangoUser

  WALLET_NORMAL_TAG       = nil
  WALLET_BONUS_TAG        = 'Bonus'
  WALLET_TRANSFERT_TAG    = 'Transfert'  

  attr_reader :user
  delegate :address, :country_of_residence, :nationality, :first_name, :last_name, to: :user_data

  def initialize(user)
    @user = user
  end

  def id_for_api
    raise Mango::UserDoesNotHaveAccount if user.mango_id.nil?
    user.mango_id
  end

  def wallets
    @wallets ||= Mango.normalize_response(MangoPay::User.wallets(id_for_api))
  end

  def normal_wallet
    wallets.find{|w| w.tag == WALLET_NORMAL_TAG}
  end

  def bonus_wallet
    wallets.find{|w| w.tag ==  WALLET_BONUS_TAG}
  end

  def transaction_wallet
    wallets.find{|w| w.tag ==  WALLET_TRANSFERT_TAG}
  end

  def total_wallets_in_cents
    normal_wallet.balance.amount + bonus_wallet.balance.amount
  end

  def user_data
    @user_data ||= Mango.normalize_response(MangoPay::NaturalUser.fetch(id_for_api))
  end

  def transactions
    @transactions ||= Mango.normalize_response(
      MangoPay::User.transactions(id_for_api, {'sort' => 'CreationDate:desc', 'per_page' => 100}))
  end

  def cards
    @cards ||= Mango.normalize_response(
      MangoPay::User.cards(id_for_api, {'sort' => 'CreationDate:desc', 'per_page' => 100}))
  end

  def valid_cards
    cards.map{|c| c.validity == "VALID" && c.active}
  end

end