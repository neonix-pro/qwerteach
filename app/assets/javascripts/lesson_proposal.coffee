class window.LessonProposal extends window.LessonForm

  initialize: ->
    super
    @showHideWarning()

  initEvents: ->
    super
    @$el.on 'click', '[data-student-id]', (ev)=> @selectStudent(ev)
    @$el.on 'change', '#pay_afterwards', (e) => @onPayAfterwardsChange(e)

  isFreeLession: -> false

  selectStudent: (ev)->
    $target = $(ev.currentTarget)
    studentId = $target.data('student-id')
    @$('#proposal_student_id').val $target.data('student-id')
    @$('.students-select-btn').text $target.text()
    if $target.data('payment') == true
      @$('.pay-afterwards-field').removeClass('hidden')
    else
      @$('.pay-afterwards-field').addClass('hidden').find("input[type='checkbox']").prop('checked', false)

  calculatePrice: ->
    return if !@isReadyForCalculating()
    @displayRecap(@paramsForDisplay())
    $.post @getCalculateUrl(), @paramsForCalculating(), (data)=>
      $('#proposal_price').val data.price


  onPayAfterwardsChange: (e)->
    if e.target.checked
      $('#warning').show()
    else
      $('#warning').hide()

  showHideWarning: ->
    if $('#pay_afterwards').checked
      $('#warning').show()
    else
      $('#warning').hide()
