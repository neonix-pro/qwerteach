require "rails_helper"

RSpec.describe GlobalRequestsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/global_requests").to route_to("global_requests#index")
    end

    it "routes to #new" do
      expect(:get => "/global_requests/new").to route_to("global_requests#new")
    end

    it "routes to #show" do
      expect(:get => "/global_requests/1").to route_to("global_requests#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/global_requests/1/edit").to route_to("global_requests#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/global_requests").to route_to("global_requests#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/global_requests/1").to route_to("global_requests#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/global_requests/1").to route_to("global_requests#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/global_requests/1").to route_to("global_requests#destroy", :id => "1")
    end

  end
end
