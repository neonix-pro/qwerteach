require 'rails_helper'

RSpec.describe "LessonPacks", type: :request do
  describe "GET /lesson_packs" do
    it "works! (now write some real specs)" do
      get lesson_packs_path
      expect(response).to have_http_status(200)
    end
  end
end
