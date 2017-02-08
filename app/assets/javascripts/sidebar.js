$(document).ready(function () {
    var h1 = $('.main-content').innerHeight();
    var h4 = $('.main-content div').innerHeight();
    var h2 = $('#footer').offset().top - $(window).height();
    footerScroll(h2);
    bodySidebarHeight(h1, h4);
    $( window ).scroll(function() {
        var h1 = $('#footer').offset().top - $(window).height();
        footerScroll(h1);
    });
});

function bodySidebarHeight(h1, h4){
    if(h1>h4){
        $('.main-content').css({position: 'relative', height: '100%'});
    }
    else{
        $('.main-content').css({position: 'relative', height: 'auto'});
    }
}

function footerScroll(h1){

    if($(window).scrollTop() > h1 )
    {
        // Footer visible
        $('nav.sidebar').css({
            position: 'absolute',
            top: h1
        });
        $('#sidebar-profile').css({
            position: 'absolute',
            top: h1 - 50,
            width:256
        });
    }
    else  if($(window).scrollTop() <= (50 + $('#flash-messages').height()))
    {
        //navbar visible
        $('nav.sidebar').css({
            position: 'absolute',
            top: 50
        });
        $('#sidebar-profile').css({
            float: 'left',
            position: 'relative',
            top: 0,
            width: 256
        });
    }
    else
    {

        // footer et navbar invisibles
        $('nav.sidebar').css({
            position: 'fixed',
            top: 0
        });
        $('#sidebar-profile').css({
            position: 'fixed',
            top: 0,
            width: 256
        });
    }
}