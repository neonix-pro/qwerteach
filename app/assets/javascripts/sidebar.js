$(document).ready(function () {
    footerScroll();
    $( window ).scroll(function() {
        footerScroll();
    });
});

function footerScroll(){
    h1 = $('#footer').offset().top - $(body).height();
    if($(window).scrollTop() > h1)
    {
        // Footer visible
        $('nav.sidebar').css({
            position: 'absolute',
            top: h1
        });
        $('#sidebar-profile').css({
            position: 'absolute',
            top: h1,
            width:256
        });
    }
    else if($(window).scrollTop() >= 50)
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
    else
    {
        //navbar visible
        $('nav.sidebar').css({
            position: 'relative',
            top: 0
        });
        $('#sidebar-profile').css({
            float: 'left',
            position: 'relative',
            top: 0,
            width: 256
        });
    }
}