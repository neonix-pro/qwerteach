$(document).on('turbolinks:load',  function() {
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

        },
        eventSources: [{
            url: '/calendar_index/'+$('#profile-calendar').attr('data-teacher-id')
        }],
    });

    $('#dashboard-lessons-calendar').fullCalendar({
        defaultView: 'month',
        eventSources: [{
            url: 'calendar_index'
        }],
        lang: 'fr',
        height: 450,
        header: {
            left:   'title',
            center: '',
            right:  'prev, next'
        }
    });

});