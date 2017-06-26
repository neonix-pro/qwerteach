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
    @toggleCardFields()

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
    $('#edit_user button[type=submit]').prop('disabled', true)
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
    else if @options.payment_url
      paymentUrl = @options.payment_url.replace('__CARD_ID__', cardId)
      $.ajax url: paymentUrl, type: 'PUT', dataType: 'script'
    else
      @$('#card_id').prepend('<option value="'+cardId+'"></option>').val(cardId);
      @$('#card_id').trigger('input');
      $('#edit_user').submit();
    @showLoader()

  registrationError: (res)->
    alert "Une erreur est survenue lors de l'enregistrement de la carte. Code: #{res.ResultCode} , message: #{I18n.t res.ResultMessage}"
    $('#edit_user button[type=submit]').prop('disabled', false)
    
  showLoader: ->
    $('#step3').html('<div class="text-center"><i class="fa fa-spin fa-3x fa-spinner text-green"></i></div>')