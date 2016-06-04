FactoryGirl.define do
  factory :user do
    email "a@a.a"
    password "kaltrina"
    password_confirmation "kaltrina"
    confirmed_at Date.today
  end
  factory :admin, class: User do
    email "d@d.d"
    password "kaltrina"
    password_confirmation "kaltrina"
    admin true
    confirmed_at Date.today
  end
  factory :prof, class: User do
    email "d@d.d"
    password "kaltrina"
    password_confirmation "kaltrina"
    postulance_accepted true
    confirmed_at Date.today
  end
end