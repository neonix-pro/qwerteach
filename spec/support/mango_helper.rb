module MangoHelper
  def mango_transaction(params = {})
    Mango.normalize_response({
      "Id" => params[:id] || "8494514",
      "CreationDate" => 12926321,
      "Tag" => "custom meta",
      "DebitedFunds" => {
          "Currency" => "EUR",
          "Amount" => ((params[:debit] || 0) * 100).round
      },
      "CreditedFunds" => {
          "Currency" => "EUR",
          "Amount" => ((params[:credit] || 0) * 100).round
      },
      "Fees" => {
          "Currency" => "EUR",
          "Amount" => ((params[:fees] || 0) * 100).round
      },
      "DebitedWalletId" => "8519987",
      "CreditedWalletId" => "8494559",
      "AuthorId" => "8494514",
      "CreditedUserId" => "8494514",
      "Nature" => "REGULAR",
      "Status" => params[:status] || "SUCCEEDED",
      "ExecutionDate" => 1463496101,
      "ResultCode" => "000000",
      "ResultMessage" => "The transaction was successful",
      "Type" => params[:type] || "PAYIN"
    })
  end
end

RSpec.configure do |config|
  config.include MangoHelper
end