# Student select
jQuery ->
  $(document).on 'click', '[data-student-id]', (ev)->
    $target = $(ev.currentTarget)
    $selector = $target.closest('.student-select')
    studentId = $target.data('student-id')
    studentIdElement = $selector.find('input')
    studentIdElement.val $target.data('student-id')
    $selector.find('.students-select-btn').text $target.text()
    $target.trigger('change', { studentId, payment: $target.data('payment') })