$(document).ready(function(){
  var limit = 3;  // limite initiale
  var offset = 0; // offset initial
  var shown = 0; // nombre de notificatiosn quie sont affichées ==> ré initialisé à "limit" si on ferme et rouvre le menu

  $('#notifications-dropdown').on('click', function (){
    if(!$(this).hasClass('open'))
    {
      shown = limit;
      $('#notifications-wrapper').empty();
      $('#notifications-wrapper').html('<i class="fa fa-spin fa-spinner"></i>');
      loadNotifications(limit, offset);
    }
  });

  $('.see-more-notifications').on('click', function(e){
    e.stopPropagation();
    loadNotifications(limit, shown);
    shown += limit;
  });

  function loadNotifications(limit, offset)
  {
    $.get('/notifications', {limit: limit, offset:offset} , function(answer){
        $('#notifications-wrapper .fa-spin').remove();
        $('#notifications-wrapper').append(answer);
      }, 'html');
  }


  function numberOfUnread()
  {

  }
});