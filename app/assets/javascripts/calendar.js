$(document).ready(function() {
    $('#profile-calendar').fullCalendar({
        defaultView: 'agendaWeek',
        eventSources: [
        ],
        allDaySlot : false,
        slotDuration: '01:00:00',
        slotLabelInterval: '02:00:00',
        height: 'auto',
        minTime: '08:00:00',
        maxTime: '23:59:59',
        dayClick: function(date, jsEvent, view) {
            $('#request-lesson').modal('show');
        }
    });
});