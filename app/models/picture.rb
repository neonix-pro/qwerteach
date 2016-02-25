class Picture < ActiveRecord::Base
  belongs_to :gallery
  # Fichier attaché avec attributs possibles
  # Accès : picture.image.url
  has_attached_file :image,
                    :path => ":rails_root/public/images/:id/:filename",
                    :url  => "/images/:id/:filename",
                    :styles => { :small => "100x100#", medium: "300x300>", :large => "500x500>" },
                    :processors => [:cropper], default_url: "/system/defaults/:style/missing.png"

  validates_attachment_content_type :image, :content_type => [ /^image\/(?:jpeg|gif|png)$/, nil ], :message => 'file type is not allowed (only jpeg/png/gif images)'
  # Crop non dispo pour les Pictures
  def cropping?
    false
  end
end
