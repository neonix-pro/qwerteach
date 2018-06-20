FactoryBot.define do
  factory :review do
    sender{ FactoryBot.create(:student) }
    subject{ FactoryBot.create(:teacher) }
    note { rand(5) + 1 }
    review_text { FFaker::Lorem.sentence }
  end
end