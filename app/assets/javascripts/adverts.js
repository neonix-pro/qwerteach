$(document).ready(function () {
    animateAdvertFields();
    
    //Cours gratuit annonce
    if($("#cmn-toggle-4").attr('checked')){
        $("#cours_gratuit_info").text("Félécitations! Les élèves ont la possibilité de réserver un premier cours gratuit avec vous.");
        $("#cours_gratuit_info").css("color", "#29B46C");
    }else {
        $("#cours_gratuit_info").text("Pour le moment, les élèves ont la possibilité de réserver un premier cours gratuit avec vous.");
        $("#cours_gratuit_info").css("color", "#D92D9B");
    }
});

function animateAdvertFields() {
    $('.topic_choice').on('change', function () {
        $.ajax({
            url: "/level_choice",
            data: {topic_id: $('.topic_choice option:selected').val()}
        });
        var choice = $('.other_name');
        choice.empty();
        if ($('.topic_choice option:selected').text() == "Other") {
            var l = '<label for="other_name">Autre matière</label>';
            var f = '<input type="text" name="advert[other_name]" id="advert[other_name]" class="form-control" required="required"/>';
            choice.append(l + f);
        }
    });

    $('#advert_topic_group_id').on('change', function () {
        $.ajax({
            url: "/topic_choice",
            data: {group_id: $('#advert_topic_group_id option:selected').val()}
        })
    });
}