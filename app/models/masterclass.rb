class Masterclass < ActiveRecord::Base
  has_one :bbb_room
  belongs_to :admin, :class_name => 'User', :foreign_key  => "admin_id"

  scope :with_room, -> {includes(:bbb_room).where.not(:bigbluebutton_rooms => { :id => nil })}

  def running?
    if bbb_room && bbb_room.fetch_is_running?
      return true
    end
    false
  end
end
