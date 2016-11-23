# shared controller methods linked to mangopay account
module MangopayAccount extend ActiveSupport::Concern

  def mango_account_params
    params.fetch(:account).permit!
  end
end