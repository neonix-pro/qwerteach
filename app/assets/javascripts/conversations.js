
var chat = function(id){
    var cb = $("#chatbox_"+id+" .conversation-content");
    cbScroll();

    $(document).on('click', '[data-toggle="loader"]', function(){
        $('.loader').fadeIn('slow');
    });
    $(document).on('click', "#chatbox_"+id+" .chatboxtextarea", function () {
        markMessagesAsRead();
    });

    function cbScroll(){
        if (cb.length){
            cb.scrollTop(cb[0].scrollHeight);
        }
    }
    function markMessagesAsRead(){
        $.ajax({
            dataType: 'text/html',
            url: "/conversations/"+id+"/mark_as_read",
            data: {conversation_id: id},
            method: 'post'
        })
            .always(function(){
                Messages.numberOfUnreadMessages();
            });
    }
}