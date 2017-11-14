require 'rails_helper'

RSpec.describe GalleriesController, type: :controller do

  let(:user) { create(:student) }
  let(:gallery){ user.gallery }
  let(:other_gallery){ create(:student).gallery }
  before :each do
    sign_in user
  end

  it "should have a current_user" do
    expect(subject.current_user).to_not eq(nil)
  end
  it "should get show : his gallery" do
    get 'show', :id => gallery.id
    expect(response).to be_success
  end
  it "should get show : other gallery" do
    get 'show', :id => other_gallery.id
    expect(response).to be_success
  end
  it "should get edit : his gallery" do
    get 'edit', :id => gallery.id
    expect(response).to be_success
  end
  it "shouldn't get show : inexistant gallery" do
    expect {
      get 'show', :id => 34
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
  it "should put edit : his gallery" do
    put 'edit', :id => gallery.id, :images => []
    expect(response).to be_success
  end
  it "shouldn't get edit : other gallery" do
    get 'edit', :id => other_gallery.id
    expect(response).to redirect_to root_path
  end
  it "shouldn't get edit : other gallery" do
    put 'edit', :id => other_gallery.id, :images => []
    expect(response).to redirect_to root_path
  end
end

RSpec.describe GalleriesController, type: :controller do
  let(:user) { create(:student) }
  let(:gallery){ user.gallery }
  let(:other_gallery){ create(:student).gallery }

  it "shouldn't have a current_user" do
    expect(subject.current_user).to eq(nil)
  end
  it "shouldn't get show" do
    get 'show', :id => gallery.id
    expect(response).to redirect_to new_user_session_path
  end
  it "shouldn't get edit" do
    get 'edit', :id => gallery.id
    expect(response).to redirect_to root_path
  end
  it "shouldn't get show : inexistant gallery" do
    expect {
      get 'show', :id => 34
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
end