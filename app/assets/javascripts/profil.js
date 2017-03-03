var col;


//Edit profil panel toogle
$(document).on('turbolinks:load',  function(){
    $(".edit_profile .title").click(function(){
        $(".colonne").fadeOut("slow");
        col = $(this).attr("data-link");
        $(col).toggle("slow");
        return false;
    });
});