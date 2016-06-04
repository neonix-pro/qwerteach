require 'rails_helper'


RSpec.describe RegistrationsController, type: :controller do
  login_admin
  describe RegistrationsController do
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end
    it "should have a current_user" do
      expect(subject.current_user).to_not eq(nil)
    end
    it "should get edit" do
      get 'edit'
      expect(response).to be_success
    end
    it "shouldn't get new" do
      @attr = {:email => "y@y.y", :password => "password", :remember_me => 0}
      get 'new', :user => @attr
      expect(response).to_not be_success
    end
    it "shouldn't post create" do
      @attr = {:email => "k@k.k", :password => "password", :password_confirmation => "password"}
      post 'create', :user => @attr
      expect(response).to_not be_success
      expect(User.last.email).to_not eq(@attr[:email])
    end
    it "should put update" do
      @attr = {:lastname => "bouuuuuh", :email => "y@y.y", :current_password => "password"}
      put :update, :id => subject.current_user, :user => @attr
      expect(response).to redirect_to root_path
      subject.current_user.reload
      expect(subject.current_user.lastname).to eq @attr[:lastname]
    end
    it "should get destroy" do
      get :destroy, :id => subject.current_user
      expect(response).to redirect_to root_path
    end
  end

end

RSpec.describe RegistrationsController, type: :controller do
  describe RegistrationsController do
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end
    it "shouldn't have a current_user" do
      # note the fact that you should remove the "validate_session" parameter if this was a scaffold-generated controller
      expect(subject.current_user).to eq(nil)
    end
    it "shouldn't post create : email already taken" do
      @attr = {:email => "y@y.y", :password => "password", :password_confirmation => "password"}
      post 'create', :user => @attr
      expect(response).to_not be_success
    end
    it "shouldn't post create : pwd too short" do
      @attr = {:email => "k@k.k", :password => "pwd", :password_confirmation => "pwd"}
      post 'create', :user => @attr
      expect(response).to be_success
      expect(User.last.email).to_not eq(@attr[:email])
    end
    it "shouldn't post create : pwds not same" do
      @attr = {:email => "k@k.k", :password => "passwordd", :password_confirmation => "password"}
      post 'create', :user => @attr
      expect(response).to be_success
      expect(User.last.email).to_not eq(@attr[:email])
    end
    it "shouldn't post create : not valid email" do
      @attr = {:email => "k@k", :password => "password", :password_confirmation => "password"}
      post 'create', :user => @attr
      expect(response).to be_success
      expect(User.last.email).to_not eq(@attr[:email])
    end
    it "should post create" do
      @attr = {:email => "k@k.k", :password => "password", :password_confirmation => "password"}
      post 'create', :user => @attr
      expect(response).to redirect_to root_path
      expect(User.last.email).to eq(@attr[:email])
    end
    it "shouldn't get new : wrong pwd" do
      @attr = {:email => "y@y.y", :password => "passwordddd", :remember_me => 0}
      get 'new', :user => @attr
      expect(response).to be_success
      expect(subject.current_user).to eq nil
    end
    it "shouldn't get new : wrong email" do
      @attr = {:email => "yk@yk.y", :password => "password", :remember_me => 0}
      get 'new', :user => @attr
      expect(response).to be_success
      expect(subject.current_user).to eq nil
    end
    it "shouldn't get new : nothing" do
      @attr = {:email => "", :password => "", :remember_me => 0}
      get 'new', :user => @attr
      expect(response).to be_success
      expect(subject.current_user).to eq nil
    end
    it "shouldn't get new : no pwd" do
      @attr = {:email => "y@y.y", :password => "", :remember_me => 0}
      get 'new', :user => @attr
      expect(response).to be_success
      expect(subject.current_user).to eq nil
    end
    it "shouldn't get new : no email" do
      @attr = {:email => "", :password => "password", :remember_me => 0}
      get 'new', :user => @attr
      expect(response).to be_success
      expect(subject.current_user).to eq nil
    end
    it "should get new" do
      @attr = {:email => "y@y.y", :password => "password", :remember_me => 0}
      get 'new', :user => @attr
      expect(response).to be_success
    end
  end
end