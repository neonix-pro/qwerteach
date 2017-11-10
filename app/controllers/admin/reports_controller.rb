module Admin
  class ReportsController < Admin::ApplicationController

    def lessons
      @report = LessonsReport.run(lessons_report_params)
      @entities = @report.result
    end
    alias_method :index, :lessons

    private

    def lessons_report_params
      params.slice(:page, :gradation, :date_range).tap do |p|
        p[:start_date], p[:end_date] = (p[:date_range] || '').split(' - ')
      end
    end

  end
end