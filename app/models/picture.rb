class Picture < ActiveRecord::Base
  belongs_to :gallery

  has_attached_file :image,
                    :path => ":rails_root/public/images/:id/:filename",
                    :url  => "/images/:id/:filename",
                    :styles => { :small => "100x100#", medium: "300x300>", :large => "500x500>" },
                    :processors => [:cropper], default_url: "/system/defaults/:style/missing.png"

  do_not_validate_attachment_file_type :image
    attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :reprocess_avatar, :if => :cropping?
  belongs_to :gallery
  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def avatar_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
  end

  private

  def reprocess_avatar
    avatar.reprocess!
  end
end
