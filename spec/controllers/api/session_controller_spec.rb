require 'rails_helper'

RSpec.describe Api::SessionController, type: :controller do

  describe "GET #Register" do
    it "returns http success" do
      get :Register
      expect(response).to have_http_status(:success)
    end
  end

end
