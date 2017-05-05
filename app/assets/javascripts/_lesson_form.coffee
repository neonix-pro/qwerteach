class window.LessonForm

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
    @initDatePicker()
    @initEvents()


  initEvents: ->
    @$el.on 'change', '.topic-group-select', (e)=> @onTopicGroupChange(e)
    @$el.on 'change', '.topic-select', (e)=> @onTopicChange(e)
    @$el.on 'change', '.level-select', (e)=> @onLevelChange(e)
    @$el.on 'change', '.hours-select', (e)=> @calculatePrice()
    @$el.on 'change', '.minutes-select', (e)=> @calculatePrice()
    @$el.on 'change', '#request_time_start', (e)=> @calculatePrice()
    @$el.on 'dp.change', '#time_start_picker', ()=> @calculatePrice()

  initDatePicker: ->
    $('#time_start_picker').datetimepicker
      locale: moment.locale(),
      format: "dddd DD MMMM [à] HH:mm",
      minDate: @getMinDate()
      allowInputToggle: true
      sideBySide: true

  getMinDate: ->
    moment().startOf('hour').add( Math.ceil(moment().minutes() / 15) * 15, 'minutes' )

  onTopicGroupChange: (e)->
    @displayRecap()
    topicGroupId = $(e.currentTarget).val()
    @clearSelect @$('.topic-select, .level-select')
    if topicGroupId.length > 0
      $.get @getTopicsUrl(topicGroupId), (data)=>
        $topicSelect = @$('.topic-select')
        $topicSelect.append  $('<option>').attr(value: group.id).text(group.title) for group in data.topics

  getTopicsUrl: (topicGroupId)->
    @topicsUrl.replace('__TEACHER_ID__', @options.teacher_id).replace('__TOPIC_GROUP_ID__', topicGroupId)

  onTopicChange: (e)->
    topicId = $(e.currentTarget).val()
    @clearSelect @$('.level-select')
    if topicId.length > 0
      $.get @getLevelsUrl(topicId), (data)=>
        $levelSelect = @$('.level-select')
        $levelSelect.append  $('<option>').attr(value: group.id).text(group.title) for group in data.levels
    $('.topic_row').removeClass('active');
    $('#topic_row_'+topicId).addClass('active');


  getLevelsUrl: (topicId)->
    @levelsUrl.replace('__TEACHER_ID__', @options.teacher_id).replace('__TOPIC_ID__', topicId)

  onLevelChange: (e)->
    @calculatePrice()
    levelId = $(e.currentTarget).val()
    $('.level_col').removeClass('active');
    $('.level_col_'+levelId).addClass('active');

  getCalculateUrl: ->
    @calculateUrl.replace('__TEACHER_ID__', @options.teacher_id)

  isFreeLession: -> false

  isReadyForCalculating: ->
    if $('.topic-select').length > 0 and  $('.level-select').length > 0
      $('.topic-select').val() != null and $('.level-select').val() != null
    else
      false

  displayRecap: ->


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
    datetime: $("#time_start_picker").data("DateTimePicker")?.date()
    endtime: $("#time_start_picker").data("DateTimePicker")?.date()?.add({hours: $('option:selected', $('#request_hours')).val(), minutes: $('option:selected', $('#request_minutes')).val()})

  $: (selector)-> @$el.find selector

  clearSelect: ($select)->
    $select.find('option[value!=""]').remove()

