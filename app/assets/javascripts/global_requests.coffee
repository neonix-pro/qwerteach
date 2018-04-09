class window.GlobalRequest

  topicsUrl: '/levels_by_topic/__TOPIC_ID__'

  constructor: (el, options = {}) ->
    @$el = $(el)
    @options = options
    @initialize()

  initialize: ->
    @initEvents()

  initEvents: ->
    @$el.on 'change', '.topic-select', (e)=> @onTopicChange(e)

  onTopicChange: (e)->
    topicId = $(e.currentTarget).val()
    @clearSelect @$('.level-select')
    if topicId.length > 0
      $.get @getLevelsUrl(topicId), (data)=>
        if @$('.level-select').hasClass('matterialize')
          $levelSelect = @$('.level-select select')
        else 
          $levelSelect = @$('.level-select')
        $levelSelect.append  $('<option>').attr(value: group.id).text(group.fr) for group in data
        
        # realtime edit level select || refresh
        $levelSelect.trigger('contentChanged')

  getLevelsUrl: (topicId)->
    @topicsUrl.replace('__TOPIC_ID__', topicId)

  clearSelect: ($select)->
    $select.find('option[value!=""]').remove()

  $: (selector)-> @$el.find selector