var x = 1;
$(document).ready(function(){
    
    //open block info
    $(".threecol").click(function(){
        $(".block_info").hide("slow");
        $(".triangle").hide();
        $("#" + $(this).attr("id") + " .triangle").slideToggle("slow");
        $("#option_" + $(this).attr("id")).toggle("slow")
    })
    
    //table varie couleur
    $("#option_historique table tr").each(function(){
        x=1;
        console.log(this)
        $(this).find("td").each(function(){
            if(x == 1){
                $(this).addClass("dark");
                x=0;
            }else{
                x = 1;
            }
        });
    });
    
});