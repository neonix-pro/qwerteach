class window.OffersManager
  CONSTANT1 = 'test'

  constructor: (id) ->
    @id = id
    @$el = $('#offer-form-'+@id)
    @$submit = $('#offer-form-'+@id+' input[type=submit]')
    @$title = @$el.children('.offer-title')
    @initialize()

  initialize: ->
    @initEvents()
    @$submit.hide()

  initEvents: ->
    @$el.on 'input', '.topic-group-select', (e)=> @onTopicGroupSelect(e)
    @$el.on 'input', '.topic-select', (e)=> @onTopicSelect(e)

  onTopicGroupSelect: (e)->
    $.ajax({
      method: 'GET',
      url: "/topic_choice",
      data: {group_id: $(e.currentTarget).val() }
    })

  onTopicSelect: (e)->
    $.ajax({
      method: 'GET',
      url: "/level_choice",
      data: {topic_id: $(e.currentTarget).val() },
      success: @onTopicSelectSuccess(e)
    })
    @$title.html($(e.currentTarget).find('option:selected').text())

  onTopicSelectSuccess: (e)->
    @$el.on 'input', '.price-input',(e) => @onPriceIntroduced(e)

  onPriceIntroduced: (e)->
    @$submit.show()