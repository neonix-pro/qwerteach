require 'rails_helper'

RSpec.describe GalleriesController, type: :controller do
  login_admin
  describe GalleriesController do
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end
    it "should have a current_user" do
      expect(subject.current_user).to_not eq(nil)
    end
    it "should get show" do
      get 'show', :id => Gallery.first.id
      expect(response).to be_success
    end
  end

end
RSpec.describe GalleriesController, type: :controller do
  describe GalleriesController do
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end
    it "shouldn't have a current_user" do
      expect(subject.current_user).to eq(nil)
    end
    it "shouldn't get show" do
      get 'show', :id => Gallery.first.id
      expect(response).to redirect_to new_user_session_path
    end
  end

end