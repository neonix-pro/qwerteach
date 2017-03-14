var MessagesManager = function() {

    Messages =
    {
        numberOfUnreadMessages: function () {
            $.get('/messages/count/', function (answer) {
                if (answer != 0) {
                    var oldValue = parseInt($('#unread-messages').text().replace('(', '').replace(')', ''));
                    $('#unread-messages').html('('+answer+')');
                    document.title = '(' + answer + ') Qwerteach';
                    if(oldValue < answer)
                    {
                        Messages.sound.play();
                    }
                }
                else {
                    $('#unread-messages').html('');
                    document.title = Messages.originalTitle;
                }
            });
        },
        originalTitle: document.title,
        sound: new Audio($('#notification_sound_path').text())
    }
}

$(document).on('turbolinks:load',  MessagesManager);
$(document).on('turbolinks:load',  function(){
    if($('#unread-messages').length > 0){
        var m = new MessagesManager();
        Messages.numberOfUnreadMessages();
    }
})

