class ActivityReport < LessonsReport

  DATE_FROMAT = '%Y-%m'

  METRICS = {
    lessons_count: { from: :created_lessons },
    lessons_amount: { from: :created_lessons, expression: 'SUM(lessons.price)' },
    students_count: { from: :created_lessons, expression: 'COUNT(DISTINCT lessons.student_id)' },
    new_students_count: { from: :first_student_lessons, expression: 'COUNT(DISTINCT lessons.student_id)' },
    teachers_count: { from: :created_lessons, expression: 'COUNT(DISTINCT lessons.teacher_id)' },
    new_teachers_count: { from: :first_teacher_lessons, expression: 'COUNT(DISTINCT lessons.teacher_id)' },
    disputes_count: { from: :disputes, date_column: :created_at }
  }.freeze

  private

  def metrics
    METRICS
  end

  def gradation_format
    DATE_FROMAT
  end

  def disputes
    Dispute.arel_table
  end

end