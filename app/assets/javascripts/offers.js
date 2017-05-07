$(document).on('turbolinks:load', function () {
    animateAdvertFields();
    changeText();
    $("#cmn-toggle-4").on('change', function(){
        changeText();
        $(this).closest('form').submit();
    });
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
            var f = '<input type="text" name="offer[other_name]" id="offer[other_name]" class="form-control" required="required"/>';
            choice.append(l + f);
        }
    });

    $('#offer_topic_group_id').on('change', function () {
        $.ajax({
            url: "/topic_choice",
            data: {group_id: $('#offer_topic_group_id option:selected').val()}
        })
    });
}

function changeText(){
    if($("#cmn-toggle-4").prop('checked')){
        $("#cours_gratuit_info").text("Félécitations! Les élèves ont la possibilité de réserver un premier cours gratuit avec vous.");
        $("#cours_gratuit_info").css("color", "#22de80");
    }else {
        $("#cours_gratuit_info").text("Pour le moment, les élèves n'ont pas la possibilité de réserver un premier cours gratuit avec vous.");
        $("#cours_gratuit_info").css("color", "#d92d9b");
    }
}