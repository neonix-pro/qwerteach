class window.RequestLesson

  $el: null
  options: null

  topicsUrl: '/users/__TEACHER_ID__/lesson_requests/topics/__TOPIC_GROUP_ID__'
  levelsUrl: '/users/__TEACHER_ID__/lesson_requests/levels/__TOPIC_ID__'
  calculateUrl: '/users/__TEACHER_ID__/lesson_requests/calculate'

  constructor: (el, options = {}) ->
    @$el = $(el)
    @options = options
    @initialize()

  initialize: ->
    @initEvents()


  initEvents: ->
    @$el.on 'change', '.topic-group-select', (e)=> @onTopicGroupChange(e)
    @$el.on 'change', '.topic-select', (e)=> @onTopicChange(e)
    @$el.on 'change', '.level-select', (e)=> @onLevelChange(e)
    @$el.on 'change', '.hours-select', (e)=> @calculatePrice()
    @$el.on 'change', '.minutes-select', (e)=> @calculatePrice()
    @$el.on 'change', '#free_lesson', => @onFreeChange()
    @$el.on 'change', '#request_time_start', (e)=> @calculatePrice()
    @$el.on 'submit', 'form', => @showLoader()
    @$el.on 'update', => @calculatePrice()
    @$el.find('.topic-select').trigger('change')


  onTopicGroupChange: (e)->
    topicGroupId = $(e.currentTarget).val()
    @clearSelect @$('.topic-select, .level-select')
    if topicGroupId.length > 0
      $.get @getTopicsUrl(topicGroupId), (data)=>
        $topicSelect = @$('.topic-select')
        $topicSelect.append  $('<option>').attr(value: group.id).text(group.title) for group in data

  getTopicsUrl: (topicGroupId)->
    @topicsUrl.replace('__TEACHER_ID__', @options.teacher_id).replace('__TOPIC_GROUP_ID__', topicGroupId)

  onTopicChange: (e)->
    @displayRecap(@paramsForDisplay())
    topicId = $(e.currentTarget).val()
    @clearSelect @$('.level-select')
    if topicId.length > 0
      $.get @getLevelsUrl(topicId), (data)=>
        $levelSelect = @$('.level-select')
        $levelSelect.append  $('<option>').attr(value: group.id).text(group.title) for group in data
    $('.topic_row').removeClass('active');
    $('#topic_row_'+topicId).addClass('active');


  getLevelsUrl: (topicId)->
    @levelsUrl.replace('__TEACHER_ID__', @options.teacher_id).replace('__TOPIC_ID__', topicId)

  onLevelChange: (e)->
    @calculatePrice()
    levelId = $(e.currentTarget).val()
    $('.level_col').removeClass('active');
    $('.level_col_'+levelId).addClass('active');

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

  displayRecap: (params)->
    if params.topic != 'matiere'
      $('#recap-topic .pull-right').text(params.topic)
    if params.level != 'niveau'
      $('#recap-level .pull-right').text(params.level)
    if params.hours != '00'
      $('#duration-hours').text(params.hours)
      $('#duration-minutes').text(params.minutes)
    else if params.minutes != '00'
      $('#duration-minutes').text(params.minutes+' min')
    $('#recap-date .pull-right').text(params.datetime.format('dddd D MMMM YYYY'))
    $('#recap-starttime .pull-right').text(params.datetime.format('HH:mm'))
    $('#recap-endtime .pull-right').text((params.endtime).format('HH:mm'))

  paramsForCalculating: ->
    hours: $('.hours-select').val()
    minutes: $('.minutes-select').val()
    topic_id: $('.topic-select').val()
    level_id: $('.level-select').val()

  paramsForDisplay: ->
    topic: $('option:selected', $('#request_topic_id')).text()
    level: $('option:selected', $('#request_level_id')).text()
    hours: $('option:selected', $('#request_hours')).text()
    minutes: $('option:selected', $('#request_minutes')).text()
    datetime: $("#datetimepicker").data("DateTimePicker").date()
    endtime: $("#datetimepicker").data("DateTimePicker").date().add({hours: $('option:selected', $('#request_hours')).val(), minutes: $('option:selected', $('#request_minutes')).val()})

  getCalculateUrl: ->
    @calculateUrl.replace('__TEACHER_ID__', @options.teacher_id)

  onFreeChange: ->
    if @isFreeLession()
      $('.hours-select').prop("disabled", true).val('00')
      $('.minutes-select').prop("disabled", true).val('30')
      @$el.children('form').append('<input type="hidden" name="request[hours]" value="0" class="free_lesson_duration" />')
      @$el.children('form').append('<input type="hidden" name="request[minutes]" value="30" class="free_lesson_duration" />')
    else
      $('.hours-select').prop("disabled", false)
      $('.minutes-select').prop("disabled", false)
      @$el.find('.free_lesson_duration').remove()


  isFreeLession: ->
    $('#free_lesson').prop('checked')

  isReadyForCalculating: ->
    $('.topic-select').val().length and $('.level-select').val().length

  clearSelect: ($select)->
    $select.find('option[value!=""]').remove()

  $: (selector)-> @$el.find selector



