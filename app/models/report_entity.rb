class ReportEntity < ActiveRecord::Base
  self.table_name = :lessons

  def readonly?
    true
  end
end