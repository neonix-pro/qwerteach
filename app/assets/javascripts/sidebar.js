$(document).ready(function () {
    footerScroll();
    bodySidebarHeight();
    $( window ).scroll(function() {
        footerScroll();
    });
});

function bodySidebarHeight(){
    h1 = $('.main-content').innerHeight();
    h2 = $('.sidebar').height();
    h3 = $(body).height();
    if(h1<h3){
        console.log('resize');
        $('.main-content').height(h3);
    }
}

function footerScroll(){
    h1 = $('#footer').offset().top - $(body).height();
    if($(window).scrollTop() > h1 )
    {
        console.log('footer');
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
    else  if($(window).scrollTop() <= 50)
    {
        console.log('nav');
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
else
    {
        console.log('none');
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