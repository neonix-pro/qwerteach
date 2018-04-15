require "rails_helper"

RSpec.describe LessonPacksController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/lesson_packs").to route_to("lesson_packs#index")
    end

    it "routes to #new" do
      expect(:get => "/lesson_packs/new").to route_to("lesson_packs#new")
    end

    it "routes to #show" do
      expect(:get => "/lesson_packs/1").to route_to("lesson_packs#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/lesson_packs/1/edit").to route_to("lesson_packs#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/lesson_packs").to route_to("lesson_packs#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/lesson_packs/1").to route_to("lesson_packs#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/lesson_packs/1").to route_to("lesson_packs#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/lesson_packs/1").to route_to("lesson_packs#destroy", :id => "1")
    end

  end
end
