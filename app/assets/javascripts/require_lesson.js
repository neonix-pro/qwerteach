$(document).ready(function () {
     $('.firstLessonFree').on('click', function () {
        var a = $(this).val();
        if ($(this).is(":checked")){
            $("#date_lesson_hour").prop("disabled", true);
            $("#date_lesson_minute").prop("disabled", true);
             $('#date_lesson_hour option[value="00"]').prop('selected', true);
             $('#date_lesson_minute option[value="30"]').prop('selected', true);
          }else{
            $("#date_lesson_hour").removeAttr('disabled');
            $("#date_lesson_minute").removeAttr('disabled');
     }} );
     
    if ($('#lesson_teacher_id').val()) {
        $.ajax({
            url: '/adverts_user/' + $('#lesson_teacher_id').val()
        }).done(function (e) {
            var topic_group = '<div class="field">';
            topic_group += '<label for="lesson_topic_group">Topic group</label>';
            topic_group += '<select id="lesson_topic_group_id" name="lesson[topic_group_id]" class="form-control" required="required">';
            topic_group += '<option disabled selected value> -- sélecitonnez une option -- </option>'
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
                topic += '<select id="lesson_topic_id" name="lesson[topic_id]" class="form-control" required="required">';
                topic += '<option disabled selected value> -- sélecitonnez une sous-option -- </option>';
                e.forEach(function (s) {
                    var tg = $('#lesson_topic_group_id option:selected').val();
                    var t = s['topic'];
                    if (tg == t['topic_group']['id']) {
                        topic += '<option value=' + t['id'] + '>' + t['title'] + '</option>';
                    }
                });
                topic += '</select>';
                topic += '</div>';
                $('#choices_lessons_topic').append(topic);
            };

            var level_choice = function () {
                var levels = '<div class="field" id="lesson_level_id_field">';
                levels += '<label for="lesson_level">Level</label>';
                levels += '<select id="lesson_level_id" name="lesson[level_id]" class="form-control" required="required">';
                levels += '<option disabled selected value> -- sélecitonnez un niveau -- </option>';
                e.forEach(function (s) {
                    var t = $('#lesson_topic_id option:selected').val();
                    var lvl = s['advert_prices'];
                    if (s['topic_id'] == t) {
                        lvl.forEach(function (l) {
                            levels += '<option data-price="' + l['price'] + '" value=' + l['level']['id'] + '>' + l['level']['fr'] + '<i id="price_level"> ' + l['price'] + '</i>' + '</option>'
                        });
                    }
                });
                levels += '</select>';
                levels += '</div>';
                $('#choices_lessons_level').append(levels);
            };
            var hour_choice = function () { //Enregistre l'heure souhaité pour le cour
                var end = $('#lesson_time_end');
                end.val($('#lesson_time_start').val());
                var formated_end = moment($('#lesson_time_end').val());
                var hours = $('#date_lesson_hour option:selected').val();
                var minutes = $('#date_lesson_minute option:selected').val();
                var after = moment(formated_end).add(hours, 'hours');
                after = after.add(minutes, 'minutes').format('L LT');
                end.val(after);
                calculPrice();
            };

            var calculPrice = function() { //Calcul le prix
            if($('.firstLessonFree').prop("checked") == true){ //Si la lesson est une lessons gratuite (30mn)
                var end = $('#lesson_time_end');
                end.val($('#lesson_time_start').val());
                var formated_end = moment($('#lesson_time_end').val());
                var hours = $('#date_lesson_hour option:selected').val();
                var minutes = $('#date_lesson_minute option:selected').val();
                var after = moment(formated_end).add(hours, 'hours');
                after = after.add(minutes, 'minutes').format('L LT');
                end.val(after);
                var price = 0;
                var hours = 0;
                var minutes = 30;
                $('#lesson_price').val(0);
            }else{
                var price = $('#lesson_level_id option:selected').attr('data-price');
                var hours = $('#date_lesson_hour option:selected').val();
                var minutes = $('#date_lesson_minute option:selected').val();
                $('#lesson_price').val(price * hours + (price * (minutes / 60)));
            }
            }
            
            var updatePrix = function () { //Met a jout le prix en cas de modification par User
                document.getElementById('price_shown').innerHTML = $('#lesson_price').val();
            }
            
            $('#price').append('<input id="lesson_price" name="lesson[price]" type="hidden" value="0"/>');
            updatePrix();


            topic_choice();
            level_choice();
            hour_choice();
            
            $(document.body).on('change', '#lesson_topic_group_id', function () {
                $('#lesson_topic_id_field').remove();
                topic_choice();
                updatePrix();
            });
            $(document.body).on('change', '#lesson_topic_id', function () {
                $('#lesson_level_id_field').remove();
                level_choice();
                updatePrix();
            });
            $(document.body).on('change', '#lesson_level_id', function () {
                calculPrice();
                updatePrix();
            });
            $(document.body).on('change', '#date_lesson_hour', function () {
                hour_choice();
                updatePrix();
            });
            $(document.body).on('change', '#date_lesson_minute', function () {
                hour_choice();
                updatePrix();
            });
            
            //$('#datetimepicker2').on("dp.change", function (e) {
                //$('#datetimepicker2').data("DateTimePicker").minDate(new Date(new Date().setDate(new Date().getDate() - 1)));
                //hour_choice();
              //  document.getElementById('price_shown').innerHTML = $('#lesson_price').val();
            //});
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
    }
});