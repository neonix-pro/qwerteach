class DashboardReport < ApplicationReport
  DATE_FORMAT = '%Y-%m-%d'

  date :start_date, default: ->{ 29.days.ago.to_date }
  date :end_date, default: ->{ Time.current.to_date }

  def execute
    load
  end

  private

  def load
    ReportEntity.find_by_sql(arel.to_sql)
  end

  def arel
    periods
      .project(
        periods[:period],
        coalence(lessons[:lessons_count], 0).as('lessons_count'),
        coalence(lessons[:lessons_amount], 0).as('lessons_amount')
      )
      .from(periods_cte)
      .join(Arel::Nodes::As.new(lessons_cte, lessons), Arel::Nodes::OuterJoin)
      .on(lessons[:period].eq periods[:period])
  end

  def periods
    Arel::Table.new(:periods)
  end

  def periods_cte
    Arel::Nodes::As.new(
      ReportsHelper.build_static_sql_table('period', gradation_values),
      periods
    )
  end

  def gradation_values
    date_range.map { |d| d.beginning_of_day }.uniq
  end

  def date_range
    @date_range ||= start_date..end_date
  end

  def lessons
    Lesson.arel_table
  end

  def lessons_cte
    period_expression = period_sql(:time_start)
    lessons
      .project(
        Arel.sql(period_expression).as('period'),
        lessons[:id].count.as('lessons_count'),
        lessons[:price].sum.as('lessons_amount')
      )
      .where(lessons[:time_start].between(start_date.beginning_of_day..end_date.end_of_day))
      .where(lessons[:status].eq Lesson.statuses[:created])
      .group(period_expression)
  end

  def created_lessons
    lessons.where(lessons[:status].eq Lesson.statuses[:created])
  end

  def period_sql(column)
    "DATE(#{column}) + INTERVAL 0 SECOND"
  end

end