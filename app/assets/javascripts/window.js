$(document).ready(function(e){
    
    var height
    
    height = $(window).height();
    
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
})