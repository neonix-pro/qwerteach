$(document).ready(function () {
    console.log('prout');
    $.ajax({
        url: '/adverts_user/' + $('#lesson_teacher_id').val()
    }).done(function (e) {
        console.log('pipi');
        var topic_group = '<div class="field">';
        topic_group += '<label for="lesson_topic_group">Topic group</label>';
        topic_group += '<select id="lesson_topic_group_id" name="lesson[topic_group_id]">';
        e.forEach(function (s) {
            var tg = s['topic']['topic_group'];
            topic_group += '<option value=' + tg['id'] + '>' + tg['title'] + '</option>'
        });
        topic_group += '</select>';
        topic_group += '</div>';
        $('#choices_lessons_topic_group').append(topic_group);

        var topic_choice = function () {
            var topic = '<div class="field" id="lesson_topic_id_field">';
            topic += '<label for="lesson_topic">Topic</label>';
            topic += '<select id="lesson_topic_id" name="lesson[topic_id]">';
            e.forEach(function (s) {
                var tg = $('#lesson_topic_group_id option:selected').val();
                var t = s['topic'];
                if (tg == t['topic_group']['id']) {
                    topic += '<option value=' + t['id'] + '>' + t['title'] + '</option>'
                }
            });
            topic += '</select>';
            topic += '</div>';
            $('#choices_lessons_topic').append(topic);
        };

        var level_choice = function () {
            var levels = '<div class="field" id="lesson_level_id_field">';
            levels += '<label for="lesson_level">Level</label>';
            levels += '<select id="lesson_level_id" name="lesson[level_id]">';
            e.forEach(function (s) {
                var t = $('#lesson_topic_id option:selected').val();
                var lvl = s['advert_prices'];
                if (s['topic_id'] == t) {
                    lvl.forEach(function (l) {
                        console.log(l);
                        levels += '<option data-price="' + l['price'] + '" value=' + l['level']['id'] + '>' + l['level']['fr'] + '<i id="price_level"> ' + l['price'] + '</i>' + '</option>'
                    });
                }
            });
            levels += '</select>';
            levels += '</div>';
            $('#choices_lessons_level').append(levels);
        };
        $('#price').append('<input id="lesson_price" name="lesson[price]" type="hidden" value="0"/>');


        topic_choice();
        level_choice();
        $(document.body).on('change', '#lesson_topic_group_id', function () {
            console.log('topic gorup changed');
            $('#lesson_topic_id_field').remove();
            topic_choice();
        });
        $(document.body).on('change', '#lesson_topic_id', function () {
            console.log('topic changed');
            $('#lesson_level_id_field').remove();
            level_choice();
        });
        $(document.body).on('change', '#lesson_level_id', function () {
            console.log('level changed');
            var price = $('#lesson_level_id option:selected').attr('data-price');
            console.log(price);
            var hours = $('#date_lesson_hour option:selected').val();
            var minutes = $('#date_lesson_minute option:selected').val();
            $('#lesson_price').val(price * hours + (price * (minutes / 60)));
        });
        /* $('#lesson_topic_group_id').change(function () {
         $('#lesson_topic_id_field').remove();
         topic_choice();
         });
         $('#lesson_topic_id').create(function () {
         console.log('topic changed');
         $('#lesson_topic_id_field').remove();
         level_choice();
         }); */
    });
});