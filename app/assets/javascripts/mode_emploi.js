var x = 0;

$(document).ready(function(e){
    
    //open mode emploi
    $(".open_mode_emploi").click(function(){
        if(x==0){
            $(".section_commentmarche").toggle("slow"); 
            x=1;
        }
    });
    
    //quit mode emploi
    $("#quit_mode_emploi").click(function(){
        if(x==1){
            $(".section_commentmarche").toggle("slow");
            x=0;
        }
    })
})