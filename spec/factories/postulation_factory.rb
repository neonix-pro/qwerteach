FactoryGirl.define do
  factory :postulation do
    interview_ok false
    avatar_ok false
    gen_informations_ok false
    offer_ok false
    trait :completed do
      interview_ok true
      avatar_ok true
      gen_informations_ok true
      offer_ok true
    end
  end
end