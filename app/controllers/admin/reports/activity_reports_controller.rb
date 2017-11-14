module Admin
  module Reports
    class ActivityReportsController < Admin::ApplicationController

      def index
        @report = ActivityReport.run(report_params)
        @entities = @report.result
        page = Administrate::Page::Collection.new(dashboard, order: order)

        render locals: {
          resources: @entities,
          page: page,
          show_search_bar: false
        }
      end

      def show
        @report = DashboardReport.run(details_params)
        @entities = @report.result
      end

      private

      def report_params
        params.slice(:page, :date_range, :order, :direction).tap do |p|
          p[:start_date], p[:end_date] = (p[:date_range] || '').split(' - ')
        end
      end

      def details_params
        params.slice(:date_range).tap do |p|
          p[:start_date], p[:end_date] = (p[:date_range] || '').split(' - ')
        end
      end

      def dashboard_class
        ::Reports::ActivityReportDashboard
      end

      def nav_link_state(resource)
        %i[activity_reports].include?(resource) ? :active : :inactive
      end

    end
  end
end