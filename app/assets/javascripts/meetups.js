$(function(){
  $('button.attending').on('click', function() {
    if ($(this).hasClass('active')) return;
    $(this).addClass('active');
    $('button.not-attending').removeClass('active');

    $.ajax({
        url: '/meetup/attending',
        data: {meetup_id: $("input[name='id']")[0].value, attending: 'true'},
        type: 'POST'
    }).done(function() {
      console.log('attending meetup');
    }).fail(function() {
      console.log("error");
    })
    .always(function() {
      document.location.reload(); 
    });
  });

  $('button.not-attending').on('click', function() {
    if ($(this).hasClass('active')) return;
    $(this).addClass('active');
    $('button.attending').removeClass('active');

    $.ajax({
        url: '/meetup/attending',
        data: {meetup_id: $("input[name='id']")[0].value, attending: 'false'},
        type: 'POST'
    }).done(function() {
      console.log('attending meetup');
    }).fail(function() {
      console.log("error");
    })
    .always(function() {
      document.location.reload(); 
    });
  });

  $(document).on('submit','.meetup-info form',function(){
    var venue = getFormData($('.proposed-venue form'));
    venue.date = venue.date == "" ? "" : $('#meetup-date').data("DateTimePicker").getDate().toISOString();
    var input = $("<input>")
                   .attr("type", "hidden")
                   .attr("name", "venue").val(JSON.stringify(venue));
    $(this).append($(input));
  });

  var dateISO = $('#meetup-date').attr('data-value');
  $('#meetup-date').datetimepicker();
  $('#meetup-date').data("DateTimePicker").setDate(dateISO);
  $('#meetup-date').prev('p')[0].innerHTML = moment(dateISO).format('DD/MM/YYYY, H:mm');

  $('.edit-meetup').on('click', function(){
    var no_venue = $('.proposed-venue').hasClass('hidden');
    $('.proposed-venue').removeClass('hidden');

    $(this).addClass('hidden');
    $('.edit-buttons').removeClass('hidden');
    $('.form-control-static.editable', '.meetup-info').each(function(){
      $(this).addClass('hidden');
      $(this).next().removeClass('hidden');
    });

    $('.editable', '.proposed-venue').each(function(){
      $(this).addClass('hidden');
      $(this).next().removeClass('hidden');
    });

    $('.cancel-edit').on('click', function(){
      if (no_venue == true) $('.proposed-venue').addClass('hidden');

      $('.edit-buttons').addClass('hidden');
      $('.edit-meetup').removeClass('hidden');

      $('.form-control', '.meetup-info').each(function(){
        $(this).addClass('hidden');
        $(this).prev().removeClass('hidden');
      });

      $('.form-control-static', '.proposed-venue').each(function(){
        $(this).removeClass('hidden');
        $(this).next().addClass('hidden');
      });
    });

  });

    
}) 
