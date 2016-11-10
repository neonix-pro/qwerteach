class window.CardRegistrationForm

  options: null

  $: (selector)-> @$el.find selector

  constructor: (el, options = {}) ->
    @$el = $(el)
    @options = options
    @initialize()

  initialize: ->
    @initMango()
    @initEvents()

  initMango: ->
    mangoPay.cardRegistration.init({
      cardRegistrationURL : @options.card_registration_url,
      preregistrationData : @$("input[name$='data']").val(),
      accessKey : @$("input[name$='accessKeyRef']").val(),
      Id : @options.card_registration_id
    });

  initEvents: ->
    @$el.on 'click', "input[type$=submit]", => @perform(); false
    @$el.on 'change', "select[name$=card_id]", => @toggleCardFields()

  cardData: ->
    cardNumber : @$("input[name$='cardNumber']").val(), 
    cardExpirationDate : "#{ @cardMonth() }#{ @$("#year").val().substr(2,2) }",
    cardCvx : @$("input[name$='cardCvx']").val(),
    cardType : 'CB_VISA_MASTERCARD'

  cardMonth: ->
    month = $("#date_month").val()
    month = "0#{month}" if month.length <= 1
    month

  ajaxRegistration: ->
    mangoPay.cardRegistration.registerCard @cardData(),
      (res)=> @payWithCard(res.CardId),
      (res)=> @registrationError(res)

  toggleCardFields: ->
    $select = @$('select[name$=card_id]')
    if $select.val() == ''
      @$('#new_card').removeClass('hidden')
    else
      @$('#new_card').addClass('hidden')

  perform: ->
    $select = @$('select[name$=card_id]')
    if $select.size() and $select.val() != ''
      @payWithCard $select.val()
    else
      @ajaxRegistration()
      

  payWithCard: (cardId)->
    if @$('input[name$=returnURL]').val()
      window.location = @$('input[name$=returnURL]').val()
    else
      paymentUrl = @options.payment_url.replace('__CARD_ID__', cardId)
      $.ajax url: paymentUrl, type: 'PUT', dataType: 'script'

  registrationError: (res)->
    alert "Error occured while registering the card: ResultCode: #{res.ResultCode} , ResultMessage: #{res.ResultMessage}"

