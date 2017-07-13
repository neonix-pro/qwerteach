class window.OffersManager
  TOPICAUTRE = [3, 7, 12, 18, 22, 27]

  constructor: (id, topics) ->
    @id = id
    @$el = $('#offer-form-'+@id)
    @$submit = $('#offer-form-'+@id+' input[type=submit]')
    @$title = @$el.children('.offer-title')
    @$otherName = @$el.find('.other_name')
    @$topicGroupSelect = @$el.find('.input-field.topic_group_select')
    @$textarea = @$el.find('textarea').parent()
    @topics = topics
    @initialize()

  initialize: ->
    @initEvents()
    @$textarea.hide()
    @autocompleted = false
    @$el.find('.materialize_autocomplete').materialize_autocomplete({
        data: @topics,
        limit: 20,
        onAutocomplete:(val) => @onAutocomplete(val),
        minLength: 1})
    @$topicGroupSelect.hide()

  initEvents: ->
    @$el.on 'autocomplete', '.materialize_autocomplete', (val) => @onAutocomplete(val)
    @$el.on 'keypress', '.materialize_autocomplete', (e) => @onTypeInField(e)
    @$el.on 'input', '.other_name', (e) => @onOtherNameInput(e)
    @$el.on 'change', '.topic_group_select select', (e) => @onTopicGroupSelect(e)
    @$el.on 'blur', '.materialize_autocomplete', (e) => @onTopicBlur(e)
    @$el.on 'submit', (e) => @onSubmit(e)

  onSubmit: (e)->
    e.preventDefault()
    @isTopicValid()

  isTopicValid: ->
    t = $('.materialize_autocomplete').val()
    g = @$topicGroupSelect.find('select').val()
    if t == '' || t == 'undefined'
      $('.materialize_autocomplete').addClass('invalid')
      return false
    else if !@autocompleted && !(g?)
      @$topicGroupSelect.find('input').addClass('invalid')
      return false
    else
      return true

  onTopicBlur: (e)->
    unless @autocompleted
      @$topicGroupSelect.show()
      @$otherName.val($('.materialize_autocomplete').val())
    else
      @$topicGroupSelect.hide()

  onAutocomplete: (val)->
    @autocompleted = true
    @$el.find('.materialize_autocomplete').removeClass('invalid').parent().find('span').remove()
    unless val == 'Autre'
      @$el.find('.topic_id').val(val.id)
      @$el.find('.topic_group_id').val(val.topic_group_id)
      @$topicGroupSelect.hide()
      @onTopicSelect(val.id)
      @$textarea.show()
    else
      @$textarea.hide()
      @$topicGroupSelect.show()

  onTopicSelect: (id)->
    $.ajax({
      method: 'GET',
      url: "/level_choice",
      data: {topic_id: id}
    })

  onTypeInField: (e)->
    @$el.find('.materialize_autocomplete').removeClass('invalid')
    @autocompleted = false
    @$el.find('.topic_id').val(null)
    @$el.find('.topic_group_id').val(null)
    @$textarea.hide()
    @$topicGroupSelect.hide()
    @$el.find('.level_choice_levels').html('')

  onOtherNameInput: (e)->
    @showDescriptionLevels() if @$otherName.val() != ''

  onTopicGroupSelect: (e)->
    @showDescriptionLevels() if @$topicGroupSelect.find('select').val()
    @$el.find('.topic_group_id').val(@$topicGroupSelect.find('select').val())
    @$el.find('.topic_id').val(TOPICAUTRE[+@$topicGroupSelect.find('select').val()-1])

  showDescriptionLevels: ->
    n = @$otherName.val()
    topicGroup = @$topicGroupSelect.find('select')
    g = topicGroup.val()
    if n != '' && g !=''
      @$textarea.show()
      @onTopicSelect(TOPICAUTRE[+g-1])