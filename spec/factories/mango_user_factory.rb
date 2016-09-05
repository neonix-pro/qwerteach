FactoryGirl.define do
  factory :mango_user, class: Mango::SaveAccount do
    # string :first_name, :last_name, :country_of_residence, :nationality
    # string :street, :number, :address_line1, :address_line2, :postal_code, :city, :region, :country
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    country_of_residence { FFaker::Address.country_code }
    country { FFaker::Address.country_code }
    nationality { FFaker::Address.country_code }
    city { FFaker::Address.city }
    address_line1 { FFaker::Address.street_name }
    address_line2 { FFaker::Address.building_number }
    postal_code { FFaker::AddressUK.postcode }
    region { FFaker::AddressUS.state }
  end
end