require 'rails_helper'

RSpec.describe OffersController, type: :controller do
    login_admin
  
    describe OffersController do
        before :each do
       request.env['devise.mapping'] = Devise.mappings[:user]
     end
     
        it "nombreAdvert" do
            assert_equal 4, Offer.count
        end
        
        it "user" do
          expect(subject.current_user).to_not eq(nil)
        end
        
        it "show" do
            get 'show', :id => Offer.last.id
            expect(response).to be_success
        end
        
        it "edit" do
            @offer = FactoryGirl.create(:offer)
            get 'edit', :id => Offer.last.id
            expect(response).to be_success
        end
        
        it 'delete' do
            offer_id = Offer.first.id
            get 'destroy', :id => offer_id
            expect(Offer.find_by_id(offer_id)).to be_nil
            expect(response).to have_http_status(:redirect)
        end
        
        it "nombreAdvert-1" do
            assert_equal 4, Offer.count
        end
    
   end
end 


RSpec.describe OffersController, type: :controller do
    describe OffersController do
        it "show" do
            get 'show', :id => Offer.first.id
            expect(response).to_not be_success
        end
        
        it "edit" do
            get 'edit', :id => Offer.first.id
            expect(response).to_not be_success
        end
    end
end