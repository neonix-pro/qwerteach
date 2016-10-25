$(window).ready(function(e){
    
    $(".prof").each(function(i){
        $(this).addClass("item" + i)
    })
    
    $(".toggleCCM").click(function(){
        $(".section_commentmarche").toggle("slow");
    })
    
})