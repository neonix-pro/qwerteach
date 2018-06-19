FactoryBot.define do
  factory :dispute do
    user { FactoryBot.create(:student) }
    lesson { FactoryBot.create(:lesson, :paid) }
  end
end
