class ReportEntity < ActiveRecord::Base
  self.table_name = :lessons

  attribute :period, connection.adapter_name == 'SQLite' ? Type::Date.new : Type::DateTime.new

  def readonly?
    true
  end
end