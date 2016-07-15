function htmlbodyHeightUpdate(){
    var height3 = $( window ).height()
    var height1 = $('.nav').height()+50
    height2 = $('.main-content').height();
    // if(height2 > height3){
    //     $('html').height(Math.max(height1,height3,height2)+10);
    //     $('body').height(Math.max(height1,height3,height2)+10);
    // }
    // else
    // {
    //     $('html').height(Math.max(height1,height3,height2));
    //     $('body').height(Math.max(height1,height3,height2));
    // }
}
$(document).ready(function () {
    htmlbodyHeightUpdate();
    $( window ).resize(function() {
        htmlbodyHeightUpdate()
    });
    $( window ).scroll(function() {
        htmlbodyHeightUpdate();
        footerScroll();
    });
});

function footerScroll(){
    h1 = $('#footer').offset().top - $(body).height();
    if($(window).scrollTop() > h1)
    {
        $('nav.sidebar').css({
            position: 'absolute',
            top: h1+50
        });
        $('#sidebar-profile').css({
            position: 'absolute',
            top: h1+50,
            width:256
        });
    }
    else 
    {
        $('nav.sidebar').css({
            position: 'fixed',
            top: 50
        });
        $('#sidebar-profile').css({
            position: 'fixed',
            top: 50,
            width: '20%'
        });
    }
}