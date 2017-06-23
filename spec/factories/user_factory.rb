FactoryGirl.define do
  factory :user do
    email "z@z.z"
    password "password"
    password_confirmation "password"
    birthdate { 25.years.ago }
    confirmed_at Date.today
    description ""
    factory :rand_user do
      email { FFaker::Internet.email }
      firstname { FFaker::Name.first_name }
      lastname { FFaker::Name.last_name }
    end
    factory :student, class: Student do
      email { FFaker::Internet.email }
      firstname { FFaker::Name.first_name }
      lastname { FFaker::Name.last_name }
    end
    factory :teacher, class: Teacher do
      email { FFaker::Internet.email }
      firstname { FFaker::Name.first_name }
      lastname { FFaker::Name.last_name }
      postulance_accepted true
    end
  end
  factory :admin, class: User do
    email "y@y.y"
    password "password"
    password_confirmation "password"
    admin true
    confirmed_at Date.today
  end
  factory :prof, class: User do
    email "g@g.g"
    password "password"
    password_confirmation "password"
    postulance_accepted true
    confirmed_at Date.today
  end
end 