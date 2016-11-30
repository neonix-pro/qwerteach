$(document).ready(function(e){
    
    var height;
    var width;
    
    height = $(window).height();
    width = $(window).width();
    
    //bigimage
    $(".section_bigimage").css("height", height-100);
    window.addEventListener("resize", function(){
      height = $(window).height();
      $(".section_bigimage").css("height", height-100);
    });
    window.addEventListener("orientationchange", function(){
      height = $(window).height();
      $(".section_bigimage").css("height", height-100);
    });
    
    //100window
    $(".100window").css("height", height);
    window.addEventListener("resize", function(){
      height = $(window).height();
      $(".100window").css("height", height);
    });
    window.addEventListener("orientationchange", function(){
      height = $(window).height();
      $(".100window").css("height", height);
    });
    
    //100width
    $(".100width").css("height", height);
    window.addEventListener("resize", function(){
      width = $(window).width();
      $(".100width").css("width", width);
    });
    window.addEventListener("orientationchange", function(){
      width = $(window).width();
      $(".100width").css("width", width);
    });

    $('.toggler').click(function(e){
        e.preventDefault();
        $(this).toggleClass('active');
        var t = $(this).attr('href');
        if(t === false || typeof t === typeof undefined) {
            t = $(this).attr('data-toggle');
        }
        $(t).slideToggle('slow', function(){
            $(this).addClass('active');
        });
    });
})