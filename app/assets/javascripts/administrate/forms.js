$(function () {
  $('select.autosubmit').on('change', function(ev) {
    $(ev.currentTarget).closest('form').submit()
  })
})