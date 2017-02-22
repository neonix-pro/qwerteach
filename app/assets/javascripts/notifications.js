var limit = 3;  // limite initiale
var offset = 0; // offset initial
var shown = 0; // nombre de notificatiosn qui sont affichées ==> ré initialisé à "limit" si on ferme et rouvre le menu

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

        if(answer != 0)
        {
          var oldValue = parseInt($('#unread-messages').text().replace('(', '').replace(')', ''));
          document.title = '('+answer+') Qwerteach' ;
          if(oldValue < answer)
          {
            Notifications.sound.play();
          }
        }
        else
        {
          document.title = Notifications.originalTitle;
        }
        $('#unread-notifications').html(answer);
      });
    },

    sound: new Audio($('#notification_sound_path').text()),

    originalTitle: document.title
    }

   $('#notifications-dropdown').on('click', function (){
    if(!$(this).hasClass('open'))
    {
      shown = limit;
      $('#notifications-wrapper').empty();
      //$('#notifications-wrapper').html('<i class="fa fa-spin fa-spinner"></i>');
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

// fadeUp of feedback messages
$(document).ready(function(){
    $("#flash-messages .alert button.close").click(function (e) {
        $(this).parent().slideUp('slow');
    });
});