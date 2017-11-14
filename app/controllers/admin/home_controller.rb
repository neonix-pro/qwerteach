module Admin
  class HomeController < Admin::ApplicationController

    helper_method :days

    def index
      @report = DashboardReport.run(report_params)
      @entities = @report.result
      @postulling_teachers = postulling_teachers
      @online_users = User.online
      @top_teachers = top_teachers

      @stats ||= Stats.new(days)
    end

    private

    def days
      (params[:days].try(:to_i) || 30)
    end

    def report_params
      { start_date: (days - 1).days.ago.to_date }
    end

    def nav_link_state(resource)
      resource == :home ? :active : :inactive
    end

    def top_teachers
      Teacher
        .select('users.*, count(lessons.id) as lessons_count, sum(lessons.price) as lessons_amount')
        .joins(:lessons_given)
        .where(lessons: {
          status: Lesson.statuses[:created],
          time_start: (days - 1).days.ago..Time.current
        })
        .group('users.id').order('count(lessons.id) desc').limit(5)
    end

    def postulling_teachers
      Teacher
        .includes(:postulation)
        .references(:postulation)
        .where(postulations: { admin_id: nil })
    end

  end
end