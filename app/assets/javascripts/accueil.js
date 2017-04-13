$(window).on('turbolinks:load',  function(e){
    
    var width = $(window).width();
    
    $(".prof").each(function(i){
        $(this).addClass("item" + i)
    })
    
    //toggle CCM 
    
    $(".toggleCCM").click(function(){
        $(".section_commentmarche").slideToggle("slow");
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
    resizeTeachers();

    function resizeTeachers(){
        var u = $('.section_profs').width() / 12;
        $('.section_choix').height(u);
        $('.section_profs #prof0').css({top:0, left:u*4, width: u*3, height: u*3});
        $('.section_profs #prof1').css({top:0, left:u*7, width: u*3, height:u*3});
        $('.section_profs #prof2').css({top:(0), left:10*u, width: u*2, height: u*2 });
        $('.section_profs #prof3').css({top:2*u, left:10*u, width: u*2, height: u*2});
        $('.section_profs #prof4').css({top:u*2, left:0, width: 3*u, height: 3*u});
        $('.section_profs #prof5').css({top:u*2, left:u*3, width: u, height: u});
        $('.section_profs #prof6').css({top:u*3, left:u*3, width: u*3, height: u*3});
        $('.section_profs #prof7').css({top:u*3, left:u*6, width: u*3, height:u*3});
        $('.section_profs #prof8').css({top:u*3, left:u*9, width: u, height: u});
        $('.section_profs #prof9').css({top:5*u, left:0, width: u*3, height: u*3});
        $('.section_profs #prof10').css({top:4*u, left:9*u, width: u*3, height: u*3});
        $('.section_profs #prof11').css({top:6*u, left:9*u, width: u*3, height: u*3});
        $('.section_profs #prof12').css({width:0, height:0});
        $('.section_profs').css({height: u*6});
    }

    var guitarHeight = $(window).width() / 2 * 414/532;
    $('.point1').css({top: guitarHeight * 1.5/100});
    $('.point2').css({top: guitarHeight * 8/25});
    $('.point3').css({top: guitarHeight * 31/50});
})