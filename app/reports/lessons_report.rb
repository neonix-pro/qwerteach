class LessonsReport < ApplicationReport

  GRADATIONS = %i[daily weekly monthly quarterly]

  METRICS = {
    total_count: { from: :lessons },
    created_count: { from: :created_lessons },
    created_amount: { from: :created_lessons, expression: 'SUM(lessons.price)' },
    expired_count: { from: :expired_lessons },
    unpaid_count: { from: :unpaid_lessons },
    unpaid_amount: { from: :unpaid_lessons, expression: 'SUM(lessons.price)' },
    students_count: { from: :lessons, expression: 'COUNT(DISTINCT lessons.student_id)' },
    new_students_count: { from: :first_student_lessons, expression: 'COUNT(DISTINCT lessons.student_id)' },
    teachers_count: { from: :lessons, expression: 'COUNT(DISTINCT lessons.teacher_id)' },
    new_teachers_count: { from: :first_teacher_lessons, expression: 'COUNT(DISTINCT lessons.teacher_id)' },
  }.freeze

  date :start_date, default: ->{ Date.today.beginning_of_year.to_date }
  date :end_date, default: ->{ Date.today.end_of_month.to_date }
  symbol :gradation, default: :monthly
  integer :page, default: 1
  integer :per_page, default: 20
  string :order, default: 'period'
  string :direction, default: 'desc'

  validates :gradation, inclusion: { in: GRADATIONS }

  def arel
    periods
      .project(periods[:period])
      .from(periods_cte)
      .tap { |scope| add_metrics_expressions(scope) }
      .tap{ |scope| add_default_ordering(scope) }
  end

  def total_count
    gradation_values.total_count
  end

  private

  def metrics
    METRICS
  end

  def primary_key
    periods[:period]
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
    @gradation_values ||= Kaminari
      .paginate_array(date_range.map { |d| beginning_of_period(d, gradation) }.uniq)
      .page(page).per(per_page)
  end

  def date_range
    @date_range ||= start_date..end_date
  end

  def lessons
    Lesson.arel_table
  end

  def created_lessons
    lessons.where(lessons[:price].gt 0).where(lessons[:status].eq Lesson.statuses[:created])
  end

  def expired_lessons
    lessons.where(lessons[:price].gt 0).where(lessons[:status].eq Lesson.statuses[:expired])
  end

  def unpaid_lessons
    created_lessons
      .where(lessons[:price].gt(0))
      .where(payments
        .project(1)
        .where(
          payments[:lesson_id].eq(lessons[:id])
            .and payments[:status].eq(Payment.statuses[:paid])
        ).exists.not
      )
  end

  def first_student_lessons
    created_lessons
      .where(
        lessons[:time_start].eq( created_lessons
          .project(Arel.sql('time_start').minimum)
          .where(Arel.sql('student_id').eq(lessons[:student_id]))
          .from(Arel::Nodes::As.new(lessons, Arel.sql('ls')))
        )
      )
  end

  def first_teacher_lessons
    created_lessons
      .where(
        lessons[:time_start].eq( created_lessons
          .project(Arel.sql('time_start').minimum)
          .where(Arel.sql('teacher_id').eq(lessons[:teacher_id]))
          .from(Arel::Nodes::As.new(lessons, Arel.sql('ls')))
        )
      )
  end

  def payments
    Payment.arel_table
  end

  def build_metric_expression(metric)
    params = metrics[metric]
    table = self.send(params[:from])

    date_column = params[:date_column] || :time_start
    period_expression = period_sql(date_column)

    return table
      .project(
        Arel.sql(params[:expression] || 'COUNT(*)').as('value'),
        Arel.sql(period_expression).as('foreign_key')
      )
      .where(
        Arel.sql(date_column.to_s).between(start_date.beginning_of_day..end_date.end_of_day)
      )
      .group(period_expression)
  end

  def period_sql(column)
    if sqlite?
      sqlite_period(column, gradation)
    else
      mysql_period(column, gradation)
    end
  end

  def beginning_of_period(date, period_key)
    if sqlite?
      sqlite_beginning_of_period(date, period_key)
    else
      mysql_beginning_of_period(date, period_key)
    end
  end

  def mysql_period(column, period_key)
    case period_key
    when :monthly then "LAST_DAY(#{column} - INTERVAL 1 MONTH) + INTERVAL 1 DAY"
    when :daily then "DATE(#{column}) + INTERVAL 0 SECOND"
    when :weekly then "DATE(#{column}) + INTERVAL 0 SECOND - INTERVAL WEEKDAY(#{column}) DAY"
    when :quarterly then "LAST_DAY(#{column} - INTERVAL MONTH(#{column}) MONTH) + INTERVAL 24 HOUR + INTERVAL QUARTER(#{column}) - 1 QUARTER"
    end
  end

  def mysql_beginning_of_period(date, period_key)
    case period_key
    when :monthly then date.beginning_of_month.beginning_of_day
    when :daily then date.beginning_of_day
    when :weekly then date.beginning_of_week.beginning_of_day
    when :quarterly then date.beginning_of_quarter.beginning_of_day
    end
  end

  def sqlite_period(column, period_key)
    case period_key
    when :monthly then "date(#{column}, 'start of month')"
    when :daily then "date(#{column}, 'start of day')"
    end
  end

  def sqlite_beginning_of_period(date, period_key)
    case period_key
    when :monthly then date.beginning_of_month
    when :daily then date.beginning_of_day.to_date
    when :weekly then date.beginning_of_week
    end
  end

end