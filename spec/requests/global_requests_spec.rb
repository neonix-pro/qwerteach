require 'rails_helper'

RSpec.describe "GlobalRequests", type: :request do
  describe "GET /global_requests" do
    it "works! (now write some real specs)" do
      get global_requests_path
      expect(response).to have_http_status(200)
    end
  end
end
