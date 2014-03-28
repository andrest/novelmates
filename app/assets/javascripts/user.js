$(function() {
  $('button.notify').on('click', function() {
    if ($(this).hasClass('active')) return;
    $(this).addClass('active');
    $('button.not-attending').removeClass('active');

    var meetup_id = $(this).attr('data-id');
    $.ajax({
        url: '/meetup/notify',
        data: {meetup_id: meetup_id, notify: 'true'},
        type: 'POST'
    }).done(function() {
      console.log('notify meetup');
    }).fail(function() {
      console.log("error");
    })
    .always(function() {
      document.location.reload(); 
    });
  });

  $('button.not-notify').on('click', function() {
    if ($(this).hasClass('active')) return;
    $(this).addClass('active');
    $('button.attending').removeClass('active');

    var meetup_id = $(this).attr('data-id');
    $.ajax({
        url: '/meetup/notify',
        data: {meetup_id: meetup_id, notify: 'false'},
        type: 'POST'
    }).done(function() {
      console.log('not-notify meetup');
    }).fail(function() {
      console.log("error");
    })
    .always(function() {
      document.location.reload(); 
    });
  });
})
