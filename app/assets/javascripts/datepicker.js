$(document).on('turbolinks:load',  function(){
    $('.datepicker').datepicker({
        format: 'dd/mm/yyyy',
        language: 'fr',
        autoclose: true
    });
});