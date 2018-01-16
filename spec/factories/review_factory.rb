FactoryGirl.define do
  factory :review do
    sender{ FactoryGirl.create(:student) }
    subject{ FactoryGirl.create(:teacher) }
    note { rand(5) + 1 }
    review_text { FFaker::Lorem.sentence }
  end
end