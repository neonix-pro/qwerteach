FactoryGirl.define do
  factory :dispute do
    user { FactoryGirl.create(:student) }
    lesson { FactoryGirl.create(:lesson, :paid) }
  end
end
