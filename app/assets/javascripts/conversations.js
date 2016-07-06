$(document).ready(function(){
    mailbox_links();
});

function mailbox_links(){
    $('.inbox-nav-link').click(function(){
        $('#mailbox_conversations').html('<div class="text-center"><i class="fa fa-spinner fa-spin fa-2x"></i></div>');
    });

    $('.chk_all').click(function(e){
        e.preventDefault();
        checkConversations($(this).attr('data-check'));
    });

    $('input.mail-checkbox').on('change', function(){
        if($(this).prop('checked')){
            $('#mailbox_conversations tr input').prop('checked', true);
        }
        else{
            $('#mailbox_conversations tr input').prop('checked', false);
        }
    });

    function checkConversations(type){
        $('#mailbox_conversations tr input').prop('checked', false);
        if(type == 'read') {
            $('#mailbox_conversations tr.read input').prop('checked', true);
        }
        else if(type =='unread') {
            $('#mailbox_conversations tr.unread input').prop('checked', true);
        }
        else if(type == 'all'){
            $('#mailbox_conversations tr input').prop('checked', true);
        }
    }
}
