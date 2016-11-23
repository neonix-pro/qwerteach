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
    @$el.on 'submit', 'form', => @showLoader()
    @$el.on 'update', => @hideLoader()


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
    topicId = $(e.currentTarget).val()
    @clearSelect @$('.level-select')
    if topicId.length > 0
      $.get @getLevelsUrl(topicId), (data)=>
        $levelSelect = @$('.level-select')
        $levelSelect.append  $('<option>').attr(value: group.id).text(group.title) for group in data

  getLevelsUrl: (topicId)->
    @levelsUrl.replace('__TEACHER_ID__', @options.teacher_id).replace('__TOPIC_ID__', topicId)

  onLevelChange: ->
    @calculatePrice()


  calculatePrice: ->
    return if !@isReadyForCalculating()
    if @isFreeLession()
      @$('#price_shown').text '0'
    else
      $.post @getCalculateUrl(), @paramsForCalculating(), (data)=>
        @$('#price_shown').text data.price

  paramsForCalculating: ->
    hours: $('.hours-select').val()
    minutes: $('.minutes-select').val()
    topic_id: $('.topic-select').val()
    level_id: $('.level-select').val()

  getCalculateUrl: ->
    @calculateUrl.replace('__TEACHER_ID__', @options.teacher_id)

  onFreeChange: ->
    if @isFreeLession()
      $('.hours-select').prop("disabled", true).val('00')
      $('.minutes-select').prop("disabled", true).val('30')
    else
      $('.hours-select').prop("disabled", false)
      $('.minutes-select').prop("disabled", false)


  isFreeLession: ->
    $('#free_lesson').prop('checked')

  isReadyForCalculating: ->
    $('.topic-select').val().length and $('.level-select').val().length

  clearSelect: ($select)->
    $select.find('option[value!=""]').remove()

  showLoader: ->
    @$('#lesson-details').addClass('hidden')
    @$('.modal-loader').removeClass('hidden')

  hideLoader: ->
    @$('#lesson-details').removeClass('hidden')
    @$('.modal-loader').addClass('hidden')

  $: (selector)-> @$el.find selector



