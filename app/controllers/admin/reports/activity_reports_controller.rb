module Admin
  module Reports
    class ActivityReportsController < Admin::ApplicationController
      skip_before_filter :default_params

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
        if @report.valid?
          @entities = @report.result
          @teachers = teachers
          @students = students
          @disputes = disputes
          @disputes_presenter = Administrate::Page::Collection.new(DisputeDashboard.new, order: order)
        else
          flash[:danger] = @report.errors.full_messages.first
          @entities = []
          @teachers = []
          @students = []
          @disputes = []
        end
      end

      private

      def report_params
        params.slice(:page, :date_range, :order, :direction, :gradation).tap do |p|
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
        return :active if %i[reports activity_reports].include?(resource)
        :inactive
      end

      def teachers
        Teacher
          .distinct
          .from(
            Teacher
              .select(
                'users.*',
                Lesson.arel_table[:time_start].minimum.as('first_lesson_date'),
                Lesson.arel_table[:price].sum.as('lessons_amount')
              )
              .joins(:lessons_given)
              .group('users.id'),
            :users
          )
          .joins(:lessons_given)
          .where(lessons: {
            status: Lesson.statuses[:created],
            time_start: @report.start_date.beginning_of_day..@report.end_date.end_of_day
          })
      end

      def students
        Student
          .distinct
          .from(
            Student
              .select(
                'users.*',
                Lesson.arel_table[:time_start].minimum.as('first_lesson_date'),
                Lesson.arel_table[:price].sum.as('lessons_amount')
              )
              .joins(:lessons_received)
              .group('users.id'),
            :users
          )
          .joins(:lessons_received)
          .where(lessons: {
            status: Lesson.statuses[:created],
            time_start: @report.start_date..@report.end_date
          })
      end

      def disputes
        Dispute
          .includes(:user)
          .where(created_at: @report.start_date.beginning_of_day..@report.end_date.end_of_day)
      end

    end
  end
end