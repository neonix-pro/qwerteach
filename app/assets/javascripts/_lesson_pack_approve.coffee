class window.LessonPackApprove

  constructor: () ->
    @initialize()

  initialize: () ->
    #@initEvents()
    #@changeApproveBtnState()

  initEvents: () ->
    $(document).on('change', '.lesson-pack-agree-with-lesson', (ev) => @changeApproveBtnState(ev))

  changeApproveBtnState: () ->
    if $('.lesson-pack-agree-with-lesson').size() == $('.lesson-pack-agree-with-lesson:checked').size()
      $('.btn-approve').removeClass('disabled')
      $('.message_not_approuved').addClass('hidden')
    else
      $('.btn-approve').addClass('disabled')
      $('.message_not_approuved').removeClass('hidden')