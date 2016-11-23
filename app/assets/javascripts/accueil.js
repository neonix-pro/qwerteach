$(window).ready(function(e){
    
    var width = $(window).width();
    
    $(".prof").each(function(i){
        $(this).addClass("item" + i)
    })
    
    //toggle CCM 
    
    $(".toggleCCM").click(function(){
        $(".section_commentmarche").toggle("slow");
    })
    
    //largeur de la abr de recherche 
    $(".recherche-bar").css("width", width - 300);
    window.addEventListener("resize", function(){
        width = $(window).width();
        $(".recherche-bar").css("width", width -300);
    });
    window.addEventListener("orientationchange", function(){
        width = $(window).width();
        $(".recherche-bar").css("width", width -300);
    });
})