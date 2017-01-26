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
            get 'edit', :id => Offer.first.id
            expect(response).to be_success
        end
        
        it "delete" do
            get "destroy", :id => Offer.first.id
            expect(response).to redirect_to offers_path
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