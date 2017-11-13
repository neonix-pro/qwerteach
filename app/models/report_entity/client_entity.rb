class ReportEntity
  class ClientEntity < ReportEntity

    attribute :last_seen, Type::DateTime.new
    attribute :last_lesson_date, Type::DateTime.new
    attribute :first_lesson_date, Type::DateTime.new

    attribute :avatar_file_name, Type::String.new


    has_attached_file :avatar,
      styles: {:small => "100x100#", medium: "300x300>", :large => "500x500>"},
      url: "/system/avatars/:hash.:extension", hash_secret: "laVieEstBelllllee", :hash_data => "/:attachment/:id/:style"
  end
end