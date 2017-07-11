$(function () {
  $(".form-datepicker").datepicker({
    debug: false,
    format: 'dd/mm/yyyy',
    language: 'fr'
  });
});

$(function () {
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
});