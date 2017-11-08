module Admin
  class ReportsController < Admin::ApplicationController

    def lessons
      @report = LessonsReport.run(lessons_report_params)
      @entities = @report.result
    end
    alias_method :index, :lessons

    private

    def lessons_report_params
      params.slice(:start_date, :end_date, :page)
    end

  end
end