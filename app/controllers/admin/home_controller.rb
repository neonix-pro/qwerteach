module Admin
  class HomeController < ApplicationController

    helper_method :days

    def index
      @report = DashboardReport.run(report_params)
      @entities = @report.result
      @postulling_teachers = Teacher.joins(:postulation).where(postulations: { admin_id: nil })
    end

    private

    def days
      (params[:days].try(:to_i) || 30)
    end

    def start_date
      days.days.ago
    end

    def end_date
      Time.current
    end

    def report_params
      { days: days }
    end

  end
end