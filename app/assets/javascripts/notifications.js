var limit = 3;  // limite initiale
var offset = 0; // offset initial
var shown = 0; // nombre de notificatiosn quie sont affichées ==> ré initialisé à "limit" si on ferme et rouvre le menu

var NotificationsManager = function() {

  Notifications = {
    
    loadNotifications: function(limit, offset){
      $.get('/notifications', {limit: limit, offset:offset} , function(answer){
        $('#notifications-wrapper .fa-spin').remove();
        $('#notifications-wrapper').append(answer);
        Notifications.numberOfUnreadNotifications();
      }, 'html');
    },

    numberOfUnreadNotifications: function(){
      $.get('/notifications/unread/', function(answer){
        $('#unread-notifications').html(answer);
        if(answer != 0)
        {
          document.title = '('+answer+') Qwerteach' ;
        }
        else
        {
          document.title = Notifications.originalTitle;
        }
      });
    },

    sound: new Audio('/assets/blop.mp3'),

    originalTitle: document.title
    }

   $('#notifications-dropdown').on('click', function (){
    if(!$(this).hasClass('open'))
    {
      shown = limit;
      $('#notifications-wrapper').empty();
      $('#notifications-wrapper').html('<i class="fa fa-spin fa-spinner"></i>');
      Notifications.loadNotifications(limit, offset);
    }
  });

  $('.see-more-notifications').on('click', function(e){
    e.stopPropagation();
    Notifications.loadNotifications(limit, shown);
    shown += limit;
  });
}

$(document).ready(NotificationsManager);