$(document).on('turbolinks:load', function(){
    set_time_zone_offset();
    function set_time_zone_offset() {
        var tz = jstz.determine();
        Cookies.set('time_zone', tz.name());
    }
});

