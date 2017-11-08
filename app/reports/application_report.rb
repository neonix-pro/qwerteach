class ApplicationReport < ActiveInteraction::Base

  private

  def load
    ReportEntity.find_by_sql(arel.to_sql)
  end

end