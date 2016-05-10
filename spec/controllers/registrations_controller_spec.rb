require 'rails_helper'


RSpec.describe RegistrationsController, type: :controller do
  login_admin
  describe RegistrationsController do
    it "should have a current_user" do
      # note the fact that you should remove the "validate_session" parameter if this was a scaffold-generated controller
      expect(subject.current_user).to_not eq(nil)
    end
    it "should get edit" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      get 'edit', {}
      response.should be_success
    end
  end
end
