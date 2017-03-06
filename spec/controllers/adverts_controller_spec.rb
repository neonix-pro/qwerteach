require 'rails_helper'

RSpec.describe AdvertsController, type: :controller do
    login_admin
  
    describe AdvertsController do
        before :each do
       request.env['devise.mapping'] = Devise.mappings[:user]
     end
     
        it "nombreAdvert" do
            assert_equal 4, Advert.count
        end
        
        it "user" do
          expect(subject.current_user).to_not eq(nil)
        end
        
        it "show" do
            get 'show', :id => Advert.last.id
            expect(response).to be_success
        end
        
        it "edit" do
            get 'edit', :id => Advert.first.id
            expect(response).to be_success
        end
        
        it "delete" do
            get "destroy", :id => Advert.first.id 
            expect(response).to redirect_to adverts_path
        end
        
        it "nombreAdvert-1" do
            assert_equal 4, Advert.count
        end
    
   end
end 


RSpec.describe AdvertsController, type: :controller do
    describe AdvertsController do
        it "show" do
            get 'show', :id => Advert.first.id
            expect(response).to_not be_success
        end
        
        it "edit" do
            get 'edit', :id => Advert.first.id
            expect(response).to_not be_success
        end
    end
end