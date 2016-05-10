require 'rails_helper'

RSpec.describe PicturesController, type: :controller do
  login_user
  describe PicturesController do
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end
    it "should have a current_user" do
      expect(subject.current_user).to_not eq(nil)
    end
  end
end

RSpec.describe PicturesController, type: :controller do
  describe PicturesController do
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end
    it "shouldn't have a current_user" do
      expect(subject.current_user).to eq(nil)
    end
  end
end