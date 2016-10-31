// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery.min
//= require moment
//= require users
//= require private_pub
//= require bootstrap-sprockets
//= require bootstrap-datepicker/core
//= require messages
//= require_tree .
//= require bootstrap-datetimepicker
//= require jquery_ujs
//= require jquery-ui/autocomplete
//= require autocomplete-rails
//= require ckeditor-jquery
//= require chosen-jquery
//= require jquery.form-validator
//= require jquery.turbolinks
//= require fullcalendar
//= require fullcalendar/lang/fr.js
//= require simpletextrotator
//= require mangopay-kit.min

$.validate({
    modules : 'security'
});
var show_ajax_message = function(msg, type) {
    $("#flash-messages").html('<div class="alert alert-dismissible alert-'+type+' role="alert" ><button class="close" data-dismiss="alert"><span>&times</span></button>'+msg+'</div>');
};

$(document).ajaxSuccess(function(event, request) {
    /*
    *   escape() is deprecated but encodeURI() or encodeURIComponent() don't do the trick
    *   nor does or decodeURIComponent() alone
    * */
    var msg = decodeURIComponent(escape(request.getResponseHeader('X-Message')));
    var type = request.getResponseHeader('X-Message-Type');
    if (msg != 'null') show_ajax_message(msg, type);
});

$(function () {
    $('[data-toggle="tooltip"]').tooltip()
})