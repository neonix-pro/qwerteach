class window.LevelsManager
  CONSTANT1 = 'test'

  constructor: (id) ->
    @id = id
    @$el = $('#levels-offer-'+@id)
    @initialize()

  initialize: ->
    @initEvents()

  initEvents: ->
    @$el.on 'click', '.price_box', (e)=> @onPriceBoxClick(e)

  onPriceBoxClick: (e)->
    a = $(e.currentTarget).val();
    if @$el.find('.'+a+'').attr('disabled')
      @$el.find('.'+a+'').removeAttr('disabled')
      @$el.find('.'+a+'').attr({
        'required': 'required'
      })
      @$el.find('.destroy_'+a).val(false)
    else
      @$el.find('.'+a+'').attr({
        'disabled': 'disabled'
      })
      @$el.find('.'+a+'').removeAttr('required')
      @$el.find('.destroy_'+a).val(true)