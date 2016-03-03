class AdvertPrice < ActiveRecord::Base

  belongs_to :level
  belongs_to :advert

  searchable do
    text :level do
      level(&:be)
    end
  end

end