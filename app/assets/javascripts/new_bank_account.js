$(document).ready(function(){
  $('.bank_account_type').click(function(){
    var type = $(this).val();
    $('.account_fields').hide();
    $('#account_'+type).slideDown();
    
  });
});

