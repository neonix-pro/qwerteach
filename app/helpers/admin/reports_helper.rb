module Admin
  module ReportsHelper
    def period_to_range(period)
      if period.match(/^\d{4}-\d{2}$/)
        "#{period}-01 - #{ Date.parse("#{period}-01").end_of_month.to_s }"
      else
        "#{period} - #{period}"
      end
    end
  end
end