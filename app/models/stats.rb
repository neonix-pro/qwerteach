class Stats
  attr_reader :days

  def initialize(days = nil)
    @days = days || 30
  end

  def new_student_count
    @new_student_count ||= Lesson.created
      .group(:student_id)
      .having(Lesson.arel_table[:time_start].minimum.between(days.days.ago.beginning_of_day..Time.current), Lesson.arel_table[:price].gt(0))
      .minimum(:time_start).size
  end

  def new_teachers_count
    @new_teachers_count ||= Lesson.created
      .group(:teacher_id)
      .having(Lesson.arel_table[:time_start].minimum.between(days.days.ago.beginning_of_day..Time.current))
      .minimum(:time_start).size
  end

  def today_lessons_count
    @today_lessons_count ||= Lesson.created
      .where(time_start: Time.current.beginning_of_day..Time.current.end_of_day).count
  end

  def finished_lesson_count
    @finished_lessons_count ||= Lesson.created
      .where('time_end < ?', Time.current).count
  end

  def total_users_count
    @total_users_count ||= User.active.count
  end

  def total_income
    @total_income ||= Lesson.created.sum(:price)
  end

  def last_days_income
    @last_days_income ||= Lesson.created
      .where(time_start: days.days.ago.beginning_of_day...Time.current).sum(:price)
  end

  def scheduled_lessons_count
    @scheduled_lessons_count ||= Lesson.created.where('time_start > ?', Time.current).count
  end
end