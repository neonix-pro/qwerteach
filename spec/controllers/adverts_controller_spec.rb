require 'rails_helper'

RSpec.describe AdvertsController, type: :controller do
    login_admin
  
    describe AdvertsController do
        before :each do
       request.env['devise.mapping'] = Devise.mappings[:user]
     end
     
        xit "nombreAdvert" do
            assert_equal 4, Advert.count
        end
        
        xit "user" do
          expect(subject.current_user).to_not eq(nil)
        end
        
        xit "show" do
            get 'show', :id => Advert.last.id
            expect(response).to be_success
        end
        
        xit "edit" do
            get 'edit', :id => Advert.first.id
            expect(response).to be_success
        end
        
        xit "delete" do
            get "destroy", :id => Advert.first.id 
            expect(response).to redirect_to adverts_path
        end
        
        xit "nombreAdvert-1" do
            assert_equal 4, Advert.count
        end
    
   end
end 


RSpec.describe AdvertsController, type: :controller do
    describe AdvertsController do
        xit "show" do
            get 'show', :id => Advert.first.id
            expect(response).to_not be_success
        end
        
        xit "edit" do
            get 'edit', :id => Advert.first.id
            expect(response).to_not be_success
        end
    end
end