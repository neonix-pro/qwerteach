class ClientsReport < ApplicationReport

  METRICS = {
    lessons_count: { from: :lessons_in_period },
    total_lessons_count: { from: :lessons },
    lessons_amount: { from: :lessons_in_period, expression: 'SUM(price)' },
    total_lessons_amount: { from: :lessons, expression: 'SUM(price)' },
    teachers_count: { from: :lessons_in_period, expression: 'COUNT(DISTINCT teacher_id)' },
    total_teachers_count: { from: :lessons, expression: 'COUNT(DISTINCT teacher_id)' },
    first_lesson_date: { from: :lessons, expression: 'MIN(time_start)' },
    last_lesson_date: { from: :lessons, expression: 'MAX(time_start)' },
  }.freeze

  date :start_date, default: ->{ Date.today.beginning_of_month.to_date }
  date :end_date, default: ->{ Date.today.end_of_month.to_date }
  integer :page, default: 1
  integer :per_page, default: 20

  private

  def load
    ReportEntity::ClientEntity.find_by_sql(arel.to_sql)
  end

  def metrics
    METRICS
  end

  def arel
    clients_in_period
      .project(
        clients[:id],
        clients[:firstname].as('first_name'),
        clients[:lastname].as('last_name'),
        clients[:avatar_file_name],
        clients[:last_seen])
      .tap{ |scope| add_metrics_expressions(scope) }
      .order(clients[:id].asc)
      .take(limit).skip(offset)
  end

  def clients
    User.arel_table
  end

  def clients_in_period
    clients.where(
      lessons
        .project(1)
        .where(
          lessons[:time_start].between(start_date.beginning_of_day..end_date.end_of_day)
            .and lessons[:student_id].eq clients[:id]
        ).exists
    )
  end

  def lessons
    Lesson.arel_table
  end

  def created_lessons
    lessons.where(lessons[:status].eq Lesson.statuses[:created])
  end

  def lessons_in_period
    lessons.where(lessons[:time_start].between(start_date.beginning_of_day..end_date.end_of_day))
  end

  def primary_key
    clients[:id]
  end

  def build_metric_expression(metric)
    params = METRICS[metric]
    table = self.send(params[:from])

    foreign_column = params[:foreign_key] || 'student_id'

    return table
      .project(
        Arel.sql(params[:expression] || 'COUNT(*)').as('value'),
        Arel.sql(foreign_column).as('foreign_key')
      )
      .group(foreign_column)
  end

  def total_count
    ReportEntity.connection.execute(
      clients_in_period.project(clients[:id].count.as('total_count')).to_sql
    ).first['total_count']
  end

end