module Admin
  class ReportsController < Admin::ApplicationController

    def lessons
      @report = LessonsReport.run(lessons_report_params)
      @entities = @report.result
    end
    alias_method :index, :lessons

    def clients
      @report = ClientsReport.run(clients_report_params)
      @entities = @report.result
    end

    def teachers
      @report = TeachersReport.run(clients_report_params)
      @entities = @report.result
    end

    private

    def lessons_report_params
      params.slice(:page, :gradation, :date_range).tap do |p|
        p[:start_date], p[:end_date] = (p[:date_range] || '').split(' - ')
      end
    end

    def clients_report_params
      params.slice(:page, :date_range).tap do |p|
        p[:start_date], p[:end_date] = (p[:date_range] || '').split(' - ')
      end
    end

    def nav_link_state(resource)
      return :active if resource == :reports
      resource_name = case params[:action]
      when 'clients' then :clients_reports
      when 'index' then :lessons_reports
      end

      resource_name == resource ? :active : :inactive
    end

  end
end