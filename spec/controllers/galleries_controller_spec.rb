require 'rails_helper'

RSpec.describe GalleriesController, type: :controller do
  login_user
  describe GalleriesController do

    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end
    it "should have a current_user" do
      expect(subject.current_user).to_not eq(nil)
    end
    it "should get show : his gallery" do
      get 'show', :id => subject.current_user.gallery.id
      expect(response).to be_success
    end
    it "should get show : other gallery" do
      get 'show', :id => Gallery.second.id
      expect(response).to be_success
    end
    it "should get edit : his gallery" do
      get 'edit', :id => subject.current_user.gallery.id
      expect(response).to be_success
    end
    it "shouldn't get show : inexistant gallery" do
      expect {
        get 'show', :id => 34
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
    it "should put edit : his gallery" do
      put 'edit', :id => subject.current_user.gallery.id, :images => []
      expect(response).to be_success
    end
    it "shouldn't get edit : other gallery" do
      get 'edit', :id => Gallery.first.id
      expect(response).to redirect_to root_path
    end
    it "shouldn't get edit : other gallery" do
      put 'edit', :id => Gallery.first.id, :images => []
      expect(response).to redirect_to root_path
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
    it "shouldn't get edit" do
      get 'edit', :id => Gallery.second.id
      expect(response).to redirect_to root_path
    end
    it "shouldn't get show : inexistant gallery" do
      expect {
        get 'show', :id => 34
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end