$(document).ready(function(){
  $('.bank_account_type').click(function(){
    var type = $(this).val();
    $('.account_fields').hide();
    $('#submit_new_bank_account').show();
    $('#account_'+type).slideDown();
  });

  $('#addBankAcountButton').click(function(){
    $('#addBankAccount').slideDown();
    $('#submit_new_bank_account').show();
  })
});

