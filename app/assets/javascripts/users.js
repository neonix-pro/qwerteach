$.ajaxSetup({beforeSend: function(xhr) {xhr.setRequestHeader("X-CSRF-Token", $("meta[name='csrf-token']").attr("content")); }});

var ready = function () {

    /**
     * When the send message link on our home page is clicked
     * send an ajax request to our rails app with the sender_id and
     * recipient_id
     */

    $('.start-conversation').click(function (e) {
        e.preventDefault();

        var sender_id = $(this).data('sid');
        var recipient_id = $(this).data('rip');

        $.post("/conversation/show_min", { sender_id: sender_id, recipient_id: recipient_id}, function (data) {
            chatBox.chatWith(data.conversation_id);
        });
    });

    /**
     * Used to minimize the chatbox
     */

    $(document).on('click', '.toggleChatBox', function (e) {
        e.preventDefault();

        var id = $(this).data('c');
        chatBox.toggleChatBoxGrowth(id);
    });

    /**
     * Used to close the chatbox
     */

    $(document).on('click', '.closeChat', function (e) {
        e.preventDefault();

        var id = $(this).data('cid');
        chatBox.close(id);
    });


    /**
     * Listen on keypress' in our chat textarea and call the
     * chatInputKey in chat.js for inspection
     */

    $(document).on('keydown', '.chatboxtextarea', function (event) {

        var id = $(this).data('cid');
        chatBox.checkInputKey(event, $(this), id);
    });

    /**
     * When a conversation link is clicked show up the respective
     * conversation chatbox
     */

    $('a.conversation').click(function (e) {
        e.preventDefault();

        var conversation_id = $(this).data('cid');
        chatBox.chatWith(conversation_id);
    });


    $('.ckeditor').ckeditor({
        // optional config
    });
    adjustProfileSidebar();
    function adjustProfileSidebar(){
        height= $(window).height();
        $('#sidebar-profile').height(height);
    };

    $('#profile-content .advert-flip-toggle').click(function(){
        $(this).toggleClass('active');
        $(this).parent().toggleClass('hover');
    })

    $('#rating').click(function(){
        $('html, body').animate({
            scrollTop:$('#profile-reviews').offset().top
        }, 'slow');
    });

    //search
    $('.more-results-button').click(function(){
        $(this).hide();
        $(this).parent().append('<i class="fa fa-spin fa-spinner"></i>');
    });

    $('#search-topic').click(function(){
        $('#search-topics').show();
        $('#search-topics .options-wrapper').animate({opacity: 1, marginTop: "5%"}, 500);
    });
    $('#search-sorting').click(function(){
        $('#search-sorting-options').show();
        $('#search-sorting-options .options-wrapper').animate({opacity: 1, marginTop: "20%"}, 500);
    });

    $('.scroller-down').click(function(){
        var cible = $($(this).attr('data-scroll'));
        cible.animate({
            scrollTop: cible.scrollTop()+100
        });
    });

    $('.scroller-up').click(function(){
        var cible = $($(this).attr('data-scroll'));
        cible.animate({
            scrollTop: cible.scrollTop()-100
        });
    });

    $('#search-topics .topics-list').on('scroll', function(){
        if($(this).scrollTop()==0){
            console.log('hidetop');
            $(this).siblings('.scroller-up').css({opacity:0.3});
        }
        else{
            $(this).siblings('.scroller-up').css({opacity: 1});
        }
        if($(this).scrollTop() + $(this).innerHeight() >= $(this)[0].scrollHeight-1) {
            $(this).siblings('.scroller-down').css({opacity:0.3});
        }
        else{
            $(this).siblings('.scroller-down').css({opacity:1});
        }
    });

    $('.close-search-overlay').click(function(){
        closeSearchOverlay();
    });

    $('#search-topics ul li').click(function(){
        closeSearchOverlay();
        changeText('#search-topic', $(this).text().toLowerCase());
        $('#search-topic-field').val($(this).attr('data-value'));
        newSearch();
    });
    $('#search-sorting-options ul li').click(function(){
        closeSearchOverlay();
        changeText('#search-sorting', $(this).text().toLowerCase());
        $('#search-sorting-field').val($(this).attr('data-value'));
        newSearch();
    });

    function closeSearchOverlay(){
        $('#search-sorting-options').fadeOut();
        $('#search-sorting-options .options-wrapper').attr('style', '');
        $('#search-topics').fadeOut();
        $('#search-topics .options-wrapper').attr('style', '');
    }

    function changeText(anchor, text){
        $(anchor).css({opacity: 0});
        $(anchor).text(text);
        $(anchor).animate({opacity: 1}, 500);
    }

    function newSearch(){
        $('#search-form').submit();
        $('#search-results').html('<i class="fa fa-spin fa-spinner></i>');
    }


}

$(document).ready(ready);
$(document).on("page:load", ready);


//Collapse edit profil

$(document).ready(function(){
   $(".edit_profile .menu .a").click(function(e) {
       $(".collapse").hide();
   }) 
});
