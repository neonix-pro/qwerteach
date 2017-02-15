class window.OffersManager
  CONSTANT1 = 'test'

  constructor: (id) ->
    @id = id
    @$el = $('#offer-form-'+@id)
    @$submit = $('#offer-form-'+@id+' input[type=submit]')
    @$title = @$el.children('.offer-title')
    @$otherName = @$el.find('.topic-name')
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
    @$title.attr('class', 'offer-title topic_'+$(e.currentTarget).val())
    @$title.text($(e.currentTarget).find('option:selected').text())
    @$otherName.html('')

  onTopicSelect: (e)->
    $.ajax({
      method: 'GET',
      url: "/level_choice",
      data: {topic_id: $(e.currentTarget).val() },
      success: @onTopicSelectSuccess(e)
    })
    @$title.html($(e.currentTarget).find('option:selected').text())
    if ($(e.currentTarget).find('option:selected').text() == 'Autre') #TODO: check if other from ID ?
      @$otherName.append('<label for="offer_topic_other_name">Précisez le nom de la matière</label>')
      @$otherName.append('<input type="text" class="form-control" name="offer[other_name]" required>')
    else
      @$otherName.html('')

  onTopicSelectSuccess: (e)->
    @$el.on 'input', '.price-input',(e) => @onPriceIntroduced(e)

  onPriceIntroduced: (e)->
    @$submit.show()