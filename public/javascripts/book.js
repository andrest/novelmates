$(function(){
  $('.new-meetup-btn').on('click', function() {
    $('.new-meetup').removeClass('hidden');
    $('.new-meetup-btn').addClass('hidden');
  });

  $('.add-interest').on('click', function() {
    $.ajax({
      url: '/book/interest',
      type: 'POST',
      data: {isbn: $('#isbn'), interest: $(this).parent('.interest-category').attr('data-id'), },
    })
    .done(function() {
      console.log("success");
    })
    .fail(function() {
      console.log("error");
    })
    .always(function() {
      console.log("complete");
    });
    
    $( '.remove-interest', $($(this).parent()) ).removeClass('hidden')
    $(this).addClass('hidden')
  });

  $('.remove-interest').on('click', function() {
    $( '.add-interest', $($(this).parent()) ).removeClass('hidden')
    $(this).addClass('hidden')
  });

  $('.new-meetup button.close').on('click', function() {
    $('.new-meetup').addClass('hidden');
    $('.new-meetup-btn').removeClass('hidden');
  });

  $('.pull-right.people').on('click', function(e) {
    e.stopPropagation();
  });

  var container = $('.profile-picture-wrapper');
  $.each(container, function(){
    $(this).load( '/user/'+ $(this).attr('data-user-id') + '/profile_pic' );
  });

  $('.edit-meetup').on('click', function(){
    $(this).addClass('hidden');
    $('.edit-buttons').removeClass('hidden');
    $('.form-control-static', '.meetup-info').each(function(){
      $(this).addClass('hidden');
      $(this).next().removeClass('hidden');
    });
    // $('.meetup-info').addClass('hidden');
    // $('.meetup-info-editable').removeClass('hidden');
  });

  $('.cancel-edit').on('click', function(){
    $('.edit-buttons').addClass('hidden');
    $('.edit-meetup').removeClass('hidden');

    $('.form-control', '.meetup-info').each(function(){
      $(this).addClass('hidden');
      $(this).prev().removeClass('hidden');
    });
  });

})