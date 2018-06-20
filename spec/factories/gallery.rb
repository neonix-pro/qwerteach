FactoryBot.define do
  factory :gallery do
    user_id { FactoryBot.create(:student).id }
  end
end