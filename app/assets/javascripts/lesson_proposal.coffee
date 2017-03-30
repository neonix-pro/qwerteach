class window.LessonProposal extends window.LessonForm

  initialize: ->
    super

  initEvents: ->
    super
    @$el.on 'click', '[data-student-id]', (ev)=> @selectStudent(ev)
    #@$el.on 'dp.change', '#time_start_picker', ()=> @calculatePrice()

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

