require 'rails_helper'

RSpec.describe DegreesController, type: :controller do
    login_admin
    
    describe DegreesController do
        it "user" do
             expect(subject.current_user).to_not eq(nil)
        end
        
        it "create" do
            @degree = {:id =>1 ,:title => "Baccalaureat", :institution => "Paul", :completion_year => 2000, :user_id => 2, :level_id => 11}
            get 'new', :degree => @degree
            expect(response).to be_success
        end
        
    end
end
