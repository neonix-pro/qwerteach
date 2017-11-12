class ReportEntity
  class ClientEntity < ReportEntity

    attribute :last_seen, Type::DateTime.new
    attribute :last_lesson_date, Type::DateTime.new

  end
end