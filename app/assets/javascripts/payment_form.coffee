class window.PaymentForm
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
    @$el.on 'click', ".btn-pay-by-card", => @perform(); false
    @$el.on 'change', "select[name$=card_id]", => @toggleCardFields()
    @$el.on 'change', '#payment_method', (e)=> @onPaymentMethodChange(e)
    @$el.on 'change', '#pay_by_wallet', (e)=> @onPayByWalletChange(e)
    @$el.on 'error', (e)=> @hideLoader(e)

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
    @showLoader()
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
      $.ajax url: paymentUrl, type: 'POST', dataType: 'script'
    else
      @$('#card_id').prepend('<option value="'+cardId+'"></option>').val(cardId);
      @$('#card_id').trigger('input');
      $('#edit_user').submit();

  registrationError: (res)->
    alert "Error occured while registering the card: ResultCode: #{res.ResultCode} , ResultMessage: #{res.ResultMessage}"

  showLoader: ->
    $('.lesson-payment-wrapper').addClass('hidden')
    $('.lesson-payment-loader').removeClass('hidden')

  hideLoader: ->
    $('.lesson-payment-wrapper').removeClass('hidden')
    $('.lesson-payment-loader').addClass('hidden')

  onPaymentMethodChange: (e)->
    $('.payment_method').hide()
    $('.payment_by_'+$(e.currentTarget).val()).slideDown()

  onPayByWalletChange: (e)->
    $('.payment_method').hide();
    if($(e.currentTarget).prop('checked'))
      $('.payment_by_wallet').slideDown()
      $('.choose_payment_method').addClass('inactive')
      $('#payment_method').prop('disabled', 'disabled')
    else
      $('.choose_payment_method').removeClass('inactive')
      $('#payment_method').prop('disabled', '')