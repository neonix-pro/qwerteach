var classes
var random

$(window).ready(function(e){
    
    classes = ["large","small"]
    
    $(".prof").each(function(){
        random = Math.floor(Math.random() * 2)
        $(this).addClass(classes[random]);
    })
})