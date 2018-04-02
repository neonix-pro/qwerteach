class window.RequestLesson extends window.LessonForm

  initEvents: ->
    super
    @$el.on 'change', '#free_lesson', => @onFreeChange()
    @$el.on 'submit', 'form', (e)=> @showLoader(e)
    @$el.on 'update', => @calculatePrice()
    @$el.find('.topic-select').trigger('change')
    @$el.on 'click', '.change-booking-step', (e)=> @onChangeBookingStep(e)


  displayRecap: ->
    params = @paramsForDisplay()
    if params.topic != 'matiere'
      $('#recap-topic .pull-right').text(params.topic)
    if params.level != 'niveau'
      $('#recap-level .pull-right').text(params.level)
    if params.hours != '00'
      $('#duration-hours').text(params.hours)
      $('#duration-minutes').text(params.minutes)
    else if params.minutes != '00'
      $('#duration-minutes').text(params.minutes+' min')
    if params.hours == '00'
      $('#duration-hours').text('0')
    if params.datetime
      $('#recap-date .pull-right').text(params.datetime.format('dddd D MMMM YYYY'))
      $('#recap-starttime .pull-right').text(params.datetime.format('HH:mm'))

    if params.endtime
      $('#recap-endtime .pull-right').text((params.endtime).format('HH:mm'))

  onFreeChange: ->
    @calculatePrice()
    if @isFreeLession()
      $('.hours-select').prop("disabled", true).val('00')
      $('.minutes-select').prop("disabled", true).val('30')
      $('#request_comment').prop('required', true)
      $('#request_comment').parent().prepend("<div class='alert alert-warning'>Précisez votre demande! Dans quel but demandez-vous un cours d'essai avec ce professeur?</div>")
    else
      $('.hours-select').prop("disabled", false)
      $('.minutes-select').prop("disabled", false)
      $('#request_comment').prop('required', false)
      $('#request_comment').parent().find('.alert').remove()


  onChangeBookingStep: (e)->
    @calculatePrice()
    $('#lesson-details').children('.alert').remove();
    if($(e.currentTarget).attr('data-toggle') == '#step2')
      @displayRecap()
      @initDatePicker()
      return unless @checkDescriptionFreeLesson()
      if (!@checkSelected())
        $('#lesson-details').prepend( $('#empty-fields-alert').html() );
        return

    $('.booking-step').hide().removeClass('active');
    $('h3.change-booking-step').removeClass('active');
    $('h3'+$(e.currentTarget).attr('data-toggle')+'-title').addClass('active')
    $($(e.currentTarget).attr('data-toggle')).slideToggle ->
      $(this).addClass 'active'


    if($(e.currentTarget).attr('data-toggle') != '#step3')
      $('.booking-info').removeClass('active')
      $($(e.currentTarget).attr('data-toggle')+'-booking-info').addClass('active')

  isFreeLession: ->
    $('#free_lesson').prop('checked')

  checkSelected: ->
    r = true
    $('#step1 select[required]').each ()->
      r = false if !$(this).val().length
    r

  showLoader: (e)->
    #change date format for processing by rails backend
    # TO DO: move to LessonForm (is duplicated in lessonProposal)
    $('#request_time_start').val(moment($('#request_time_start').val(), "[le] DD MMMM [à] HH:mm").format('DD/MM/YYYY HH:mm'))
    $('.lesson-payment-wrapper').addClass('hidden')
    $('.lesson-payment-loader').removeClass('hidden')

  calculatePrice: ->
    return if !@isReadyForCalculating()
    $('#precalculated-price').removeClass('updated');
    @displayRecap(@paramsForDisplay())
    if @isFreeLession()
      $('#price_shown').text '0'
    else
      $.post @getCalculateUrl(), @paramsForCalculating(), (data)=>
        $('#price_shown').text data.price
    $('#precalculated-price').addClass('updated');

  checkDescriptionFreeLesson: ->
    if @isFreeLession() && $('#request_comment').val().length < 10
      return false
    return true




