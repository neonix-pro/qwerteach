class LessonsReceivedDashboard < LessonDashboard

  SHOW_PAGE_ATTRIBUTES = [

  ]

  FORM_ATTRIBUTES = [

  ]

  COLLECTION_ATTRIBUTES = [
    :teacher,
    :topic_group,
    :topic,
    :status,
    :price,
    :time_start,
  ]
end