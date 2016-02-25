class Picture < ActiveRecord::Base
  belongs_to :gallery
  # Fichier attaché avec attributs possibles
  # Accès : picture.image.url
  has_attached_file :image,
                    :path => ":rails_root/public/images/:id/:filename",
                    :url  => "/images/:id/:filename",
                    :styles => { :small => "100x100#", medium: "300x300>", :large => "500x500>" },
                    :processors => [:cropper], default_url: "/system/defaults/:style/missing.png"

  do_not_validate_attachment_file_type :image
  # Crop non dispo pour les Pictures
  def cropping?
    false
  end
end
