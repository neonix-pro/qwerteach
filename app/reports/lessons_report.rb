class LessonsReport < ApplicationReport

  GRADATIONS = {
    monthly: '%Y-%m',
    daily: '%Y-%m-%d'
  }

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
  string :order, default: 'id'
  string :direction, default: 'asc'

  validates :gradation, inclusion: { in: GRADATIONS.keys }

  def arel
    periods
      .project(periods[:period])
      .from(periods_cte)
      .tap { |scope| add_metrics_expressions(scope) }
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
      .paginate_array(date_range.map { |d| d.strftime(gradation_format) }.uniq)
      .page(page).per(per_page)
  end

  def date_range
    @date_range ||= start_date..end_date
  end

  def gradation_format
    GRADATIONS[gradation]
  end

  def lessons
    Lesson.arel_table
  end

  def created_lessons
    lessons.where(lessons[:status].eq Lesson.statuses[:created])
  end

  def expired_lessons
    lessons.where(lessons[:status].eq Lesson.statuses[:expired])
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
    if ActiveRecord::Base.connection.adapter_name == 'SQLite'
      "strftime('#{gradation_format}', #{column})"
    else
      "DATE_FORMAT(#{column}, '#{gradation_format}')"
    end
  end

end