$(function () {
  $(".form-datepicker").datepicker({
    debug: false,
    format: 'dd/mm/yyyy',
    language: 'fr'
  });

  $(".datetimepicker").datetimepicker({
    debug: false,
    format: "YYYY-MM-DD HH:mm:ss",
    icons: {
      time: 'fa fa-clock-o',
      date: 'fa fa-calendar',
      up: 'fa fa-chevron-up',
      down: 'fa fa-chevron-down',
      previous: 'fa fa-chevron-left',
      next: 'fa fa-chevron-right',
      today: 'fa fa-crosshairs',
      clear: 'fa fa-trash',
      close: 'fa fa-remove'
    }
  });

  $("[data-behavior='daterangepicker']").each(function(i, el) {
    var $el = $(el)
    $el.daterangepicker({
      locale: {
        format: 'YYYY-MM-DD'
      },
      ranges: {
        'This Week': [moment().startOf('week'), moment().endOf('week')],
        'Last Week': [moment().subtract(7, 'days').startOf('week'), moment().subtract(7, 'days').endOf('week')],
        'This Month': [moment().startOf('month'), moment().endOf('month')],
        'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')],
        'Last 30 Days': [moment().subtract(29, 'days'), moment()],
        'Last 90 Days': [moment().subtract(89, 'days'), moment()],
      },
      alwaysShowCalendars: true,
      parentEl: $el.closest('.form-group').get(0) || 'body'
    })
  })


});