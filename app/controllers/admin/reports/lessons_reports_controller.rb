module Admin
  module Reports
    class LessonsReportsController < Admin::ApplicationController
      def index
        @report = LessonsReport.run(search_params)
        @entities = @report.result
        page = Administrate::Page::Collection.new(dashboard, order: order)

        render locals: {
          resources: @entities,
          page: page,
          show_search_bar: false
        }
      end

      private

      def search_params
        params.slice(:page, :gradation, :date_range, :order, :direction).tap do |p|
          p[:start_date], p[:end_date] = (p[:date_range] || '').split(' - ')
        end
      end

      def dashboard_class
        ::Reports::LessonsReportDashboard
      end

      def nav_link_state(resource)
        return :active if %i[reports lessons_reports].include?(resource)
        :inactive
      end
    end
  end
end