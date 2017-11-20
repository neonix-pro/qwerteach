class ReportEntity < ActiveRecord::Base
  self.table_name = :lessons

  attribute :period, Type::DateTime.new

  def readonly?
    true
  end
end