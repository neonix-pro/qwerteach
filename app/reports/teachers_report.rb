class TeachersReport < ApplicationReport

  METRICS = {
    lessons_count: { from: :lessons_in_period },
    total_lessons_count: { from: :lessons },
    lessons_amount: { from: :lessons_in_period, expression: 'SUM(price)' },
    total_lessons_amount: { from: :lessons, expression: 'SUM(price)' },
    students_count: { from: :lessons_in_period, expression: 'COUNT(DISTINCT student_id)' },
    total_students_count: { from: :lessons, expression: 'COUNT(DISTINCT student_id)' },
    first_lesson_date: { from: :lessons, expression: 'MIN(time_start)' },
    last_lesson_date: { from: :lessons, expression: 'MAX(time_start)' },
  }.freeze

  date :start_date, default: ->{ Date.today.beginning_of_month.to_date }
  date :end_date, default: ->{ Date.today.end_of_month.to_date }

  integer :page, default: 1
  integer :per_page, default: 20

  private

  def metrics
    METRICS
  end

  def load
    ReportEntity::ClientEntity.find_by_sql(arel.to_sql)
  end

  def arel
    teachers_in_period
      .project(
        teachers[:id],
        teachers[:firstname].as('first_name'),
        teachers[:lastname].as('last_name'),
        teachers[:avatar_file_name],
        teachers[:last_seen])
      .tap{ |scope| add_metrics_expressions(scope) }
      .order(teachers[:id].asc)
      .take(limit).skip(offset)
  end

  def teachers
    User.arel_table
  end

  def teachers_in_period
    teachers.where(
      lessons
        .project(1)
        .where(
          lessons[:time_start].between(start_date.beginning_of_day..end_date.end_of_day)
            .and lessons[:teacher_id].eq teachers[:id]
        ).exists
    )
  end

  def lessons
    Lesson.arel_table
  end

  def lessons_in_period
    lessons.where(lessons[:time_start].between(start_date.beginning_of_day..end_date.end_of_day))
  end

  def primary_key
    teachers[:id]
  end

  def default_foreign_column
    'teacher_id'
  end

  def total_count
    ReportEntity.connection.execute(
      teachers_in_period.project(teachers[:id].count.as('total_count')).to_sql
    ).first['total_count']
  end

end