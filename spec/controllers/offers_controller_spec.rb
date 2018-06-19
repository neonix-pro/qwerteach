require 'rails_helper'

RSpec.describe OffersController, type: :controller do
    login_admin
  
    describe OffersController do
      let!(:offers) { create_list(:offer, 4) }

      it "nombreAdvert" do
          assert_equal 4, Offer.count
      end

      it "user" do
        expect(subject.current_user).to_not eq(nil)
      end

      it "show" do
          get 'show', :id => offers.last.id
          expect(response).to be_success
      end

      it "edit" do
          @offer = FactoryBot.create(:offer)
          get 'edit', :id => offers.last.id
          expect(response).to be_success
      end

      it "delete" do
          get "destroy", :id => offers.first.id
          expect(response).to redirect_to edit_user_registration_path(offers.first.user_id)
      end
    
   end
end 


RSpec.describe OffersController, type: :controller do
    describe OffersController do
        let(:offer) { create(:offer) }

        it "show" do
            get 'show', :id => offer.id
            expect(response).to_not be_success
        end
        
        it "edit" do
            get 'edit', :id => offer.id
            expect(response).to_not be_success
        end
    end
end