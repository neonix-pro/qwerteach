class window.LessonPackForm extends window.LessonForm

  initialize: ->
    super
    @rate = null
    @newItemTemplate = @$('.fields-for-new-item').remove().html()
    @onLevelChange() if @$('.level-select').val()

  initEvents: ->
    @$el.on 'change', '.topic-select', (e)=> @onTopicChange(e)
    @$el.on 'change', '.level-select', (e)=> @onLevelChange(e)
    @$el.on 'click', '.btn-add-item', (e) => @onAddItemClick(e)
    @$el.on 'click', '.btn-remove-item', (e) => @onRemoveItemClick(e)
    @$el.on 'change', '.discount', (e) => @showRecap()
    @$el.on 'change', '.hours-select', (e) => @showRecap()
    @$el.on 'change', '.minutes-select', (e) => @showRecap()
    

  onTopicChange: (e) =>
    super
    @rate = null
    @toggleSecondPart()

  onLevelChange: (e)->
    @toggleSecondPart()
    @requestRate()

  onAddItemClick: (e)->
    e.preventDefault()
    return if @$('.lesson-pack-item').size() >= 20
      $(e.currentTarget).addClass('shaking')
      @$('.lessons_alert_box.adding_lessons').removeClass('hidden').html('Vous ne pouvez pas dépasser 20 leçons')
    @addItem()

  onRemoveItemClick: (e) ->
    e.preventDefault()
    $item = $(e.currentTarget).closest('.lesson-pack-item')
    if @$('.lesson-pack-item').size() <= 5
      alert = $('.alert-min-lessons').clone();
      $('.lesson-pack-items').prepend(alert.show()) unless $('.alert-min-lessons').length > 1
      return
    if $item.data('persisted')
      $item
        .addClass('hidden')
        .find('.delete-input').val(true)
    else
      $item.remove()
    @showRecap()

  addItem: ->
    $item = $(@newItemTemplate.replace(/__ITEM_INDEX__/g, Date.now()))
    @initDatePicker($item)
    @$('.lesson-pack-items').append($item)


  toggleSecondPart: () ->
    if @rate
      @$('.lessons-part').removeClass('hidden')
      @$('.lesson-pack-values').removeClass('hidden')
      @showRecap()
    else
      @$('.lessons-part').addClass('hidden')
      @$('.lesson-pack-values').addClass('hidden')

  requestRate: () ->
    $.post @getCalculateUrl(), @paramsForRate(), (data)=>
      @rate = data.price
      @toggleSecondPart()

  paramsForRate: () ->
    hours: 1
    minutes: 0
    topic_id: @$('.topic-select').val()
    level_id: @$('.level-select').val()

  paramsForRecap: () ->
    duration = @duration()
    cost = (@rate || 0) * duration.asHours()
    {
      rate: @rate || '-',
      hours: "#{Math.floor(duration.asHours())}:#{duration.minutes()}",
      cost: Math.round(cost, 2) || '-',
      amount: Math.round(cost * (1 - @discount() / 100), 2) || '-'
    }

  totalHours: () ->
    @$('.lesson-pack-item:not(.hidden) .hours-select')
      .toArray()
      .reduce(((st, el) => st + parseInt($(el).val(), 10)), 0)

  totalMinutes: () ->
    console.log(@$('.lesson-pack-item:not(.hidden) .minutes-select'))
    @$('.lesson-pack-item:not(.hidden) .minutes-select')
    .toArray()
    .reduce(((st, el) => st + parseInt($(el).val(), 10)), 0)

  duration: () ->
    moment.duration({ hours: @totalHours(), minutes: @totalMinutes() })

  discount: () -> parseInt(@$('.discount').val())

  showRecap: () ->
    params = @paramsForRecap()
    @$('#rate-value').text(params.rate)
    @$('#hours-value').text(params.hours)
    @$('#cost-value').text(params.cost)
    @$('#total-amount-value').text(params.amount)


