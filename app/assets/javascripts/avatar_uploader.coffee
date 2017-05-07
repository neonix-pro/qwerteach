class window.AvatarUploader

  PREVIEW_WIDTH = 200
  PREVIEW_HEIGHT= 200

  NORMAL_WIDTH = 500
  NORMAL_HEIGHT = 500

  constructor: (options = {}) ->
    @$el = $('form.avatar-uploader')
    @$placeholder = $('.avatar-uploaded-preview')
    @$submit = $('.edit-user-avatar button[type=submit]')
    @$browse = $('.edit-user-avatar button[type=button]')
    @$modal = $('#avatar-crop-modal')
    @jcrop = null
    @options = options
    @initialize()

  initialize: ->
    @initEvents()
    @$submit.hide()

  initEvents: ->
    @$el.on 'change', '#user_avatar', => @onFileSelected()
    @$modal.on 'click', '.btn-avatar-save', => @submitForm()
    @$el.on 'click', 'button.browse', => @onClickBrowse()
    @$submit.on 'click', (e)=> @onClickSubmit(e)

  onFileSelected: ->
    @$placeholder.hide()
    @$submit.show()
    file = $('#user_avatar').get(0).files[0]
    return unless file

    reader = new FileReader()
    reader.onload = =>
      $('.avatar-uploaded-view, .avatar-uploaded-preview').empty()
      $('<img>').addClass('avatar-uploaded-view-image')
        .prop('src', reader.result)
        .appendTo('.avatar-uploaded-view')

      $('<img>').addClass('avatar-uploaded-preview-image')
        .prop('src', reader.result)
        .appendTo('.avatar-uploaded-preview')

      setTimeout((=> @initCrop()), 200)
    reader.readAsDataURL(file);


  initCrop: ->
    $('.avatar-uploaded-view-image').Jcrop
      onSelect: (coords)=> this.onCropSelect(coords)
      onChange: (coords)=> this.onCropSelect(coords)
      setSelect:   [ 0, 0, PREVIEW_WIDTH, PREVIEW_HEIGHT ]
      aspectRatio: 1
      boxHeight: 400

  onCropSelect: (coords) ->
    rx = PREVIEW_WIDTH / coords.w
    ry = PREVIEW_HEIGHT / coords.h

    ratio = $('.avatar-uploaded-view-image').get(0).naturalWidth / $('.avatar-uploaded-view-image').width()

    $('.avatar-uploaded-preview-image').css
      width: Math.round(rx * $('.avatar-uploaded-view-image').width()) + 'px'
      height: Math.round(ry * $('.avatar-uploaded-view-image').height()) + 'px'
      marginLeft: '-' + Math.round(rx * coords.x) + 'px'
      marginTop: '-' + Math.round(ry * coords.y) + 'px'

    $('#crop_x').val(Math.round(coords.x * ratio))
    $('#crop_y').val(Math.round(coords.y * ratio))
    $('#crop_w').val(Math.round(coords.w * ratio))
    $('#crop_h').val(Math.round(coords.h * ratio))

  submitForm: ->
    @$el.get(0).submit()

  onClickBrowse: ->
    $('#avatar_select input').trigger('click');

  onClickSubmit: (e)->
    $(e.currentTarget).html($(e.currentTarget).attr('disable_with'))
    $(e.currentTarget).prop('disabled', true)