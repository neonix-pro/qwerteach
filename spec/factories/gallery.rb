FactoryGirl.define do
  factory :gallery do
    user_id { FactoryGirl.create(:student).id }
  end
end