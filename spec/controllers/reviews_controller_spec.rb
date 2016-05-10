require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  login_user
  describe ReviewsController do
    before :each do
      request.env['devise.mapping'] = Devise.mappings[:user]
    end
    it "should have a current_user" do
      expect(subject.current_user).to_not eq(nil)
    end
    it "should get index" do
      get :index, :user_id => subject.current_user.id
      expect(response).to be_success
    end
    it "should post create" do
      expect(subject.current_user.reviews_sent.count).to eq 0
      expect(User.first.reviews_received.count).to eq 0
      post :create, :user_id => User.first.id, :note => 4, :review_text => "a"
      expect(response).to redirect_to user_path(User.first)
      expect(subject.current_user.reviews_sent.count).to eq 1
      expect(User.first.reviews_received.count).to eq 1
      expect(User.first.reviews_received.last.note).to eq 4
      # Modif forcée de l'ancien review
      post :create, :user_id => User.first.id, :note => 5, :review_text => "a"
      expect(subject.current_user.reviews_sent.count).to eq 1
      expect(User.first.reviews_received.count).to eq 1
      expect(User.first.reviews_received.last.note).to eq 5
    end
    it "shouldn't post create : same user" do
      post :create, :user_id => subject.current_user, :note => 4, :review_text => "a"
      expect(response).to redirect_to user_path(subject.current_user)
      expect(subject.current_user.reviews_received.count).to eq 0
    end
  end
end
