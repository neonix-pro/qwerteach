FactoryGirl.define do
  factory :user do
    email "z@z.z"
    password "password"
    password_confirmation "password"
    confirmed_at Date.today
  end
  factory :admin, class: User do
    email "y@y.y"
    password "password"
    password_confirmation "password"
    admin true
    confirmed_at Date.today
  end
end