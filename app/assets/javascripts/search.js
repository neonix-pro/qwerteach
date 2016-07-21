$(document).ready(function(){
    $('.text-appear')
        .delay(500)
        .animate({ opacity: 1 }, 500);

    $('.filter').click(function(){
       $('#search-filter').val($(this).attr('data-filter'));
        $('#search-form').submit();
    });
});
