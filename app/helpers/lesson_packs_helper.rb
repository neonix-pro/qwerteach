module LessonPacksHelper

  def lesson_pack_events(lesson_pack)
    lesson_pack.items.map do |item|
      {
        start: item.time_start.iso8601,
        end: (item.time_start + item.duration.minutes).iso8601,
        title: lesson_pack.topic.try(:title)
      }
    end
  end

end