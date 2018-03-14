class window.LessonProposal extends window.LessonForm

  initialize: ->
    super
    @toggleWarning()
    @togglePayAfterwards()


  initEvents: ->
    super
    @$el.on 'change', '[data-student-id]', (ev)=> @selectStudent(ev)
    @$el.on 'change', '#pay_afterwards', (e) => @showHideWarning(e)

  isFreeLession: -> false

  selectStudent: (ev)->
    @togglePayAfterwards()

  calculatePrice: ->
    return if !@isReadyForCalculating()
    @displayRecap(@paramsForDisplay())
    $.post @getCalculateUrl(), @paramsForCalculating(), (data)=>
      $('#proposal_price').val data.price

  toggleWarning: ->
    if $('#pay_afterwards').checked
      $('#warning').show()
    else
      $('#warning').hide()

  togglePayAfterwards: ->
    id = $('#proposal_student_id').val()
    $target = $('[data-student-id='+id+']')
    if $target.data('payment')
      @$('.pay-afterwards-field').removeClass('hidden')
    else
      @$('.pay-afterwards-field').addClass('hidden').find("input[type='checkbox']").prop('checked', false)

