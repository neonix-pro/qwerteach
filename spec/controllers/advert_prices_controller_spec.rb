require 'rails_helper'

RSpec.describe AdvertPricesController, type: :controller do
    login_admin
    describe AdvertPricesController do
    before :each do
        request.env['devise.mapping'] = Devise.mappings[:user]
    end 
    
    it "user" do
        expect(subject.current_user).to_not eq(nil)
    end
    end
end