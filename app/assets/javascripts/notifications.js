$(document).ready(function(){
  $('#notifications-dropdown').on('click', function (){
    if(!$(this).hasClass('open'))
    {
      loadThreeNotifications();
    }
  });
  var listeNotifs=[]
  function loadThreeNotifications()
  {
    $.get('/notifications', function(answer){
        console.log(answer);
        $('#notifications-wrapper').append(answer);
      }, 'html');
  }
});