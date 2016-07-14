$(document).ready(function() {
    $('#profile-calendar').fullCalendar({
        defaultView: 'agendaWeek',
        eventSources: [
        ],
        firstDay: 1,
        lang: 'fr',
        allDaySlot : false,
        slotDuration: '01:00:00',
        height: 'auto',
        minTime: '08:00:00',
        maxTime: '23:59:59',
        dayClick: function(date, jsEvent, view) {
            $('#request-lesson').modal('show');
        },
        columnFormat:{
            week: 'ddd D'
        },
        events:[
            {
                title: 'test',
                start: '2016-07-13T08:00:00',
                end: '2016-07-13T10:00:00'
            }
        ]

    });
});