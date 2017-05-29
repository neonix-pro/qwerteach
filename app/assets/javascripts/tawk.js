
$(document).on('turbolinks:load', function(){
    $('.open-tawk').click(function(e){
        e.preventDefault();
        Tawk_API.maximize();
    });
});
