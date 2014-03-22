$(function(){
  $('.new-meetup-btn').on('click', function() {
    $('.new-meetup').removeClass('hidden');
    $('.new-meetup-btn').addClass('hidden');
  });
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


  $('.add-interest').on('click', function() {
    var interest_category = $(this).parents('.interest-category');
    var interest = interest_category.children('.interest-name')[0].value;
    if (interest != undefined) {
      if (interest == "") {
        return;
      }
      var copy = interest_category.clone()
      $('input', copy)[0].value = "";
      $(interest_category).parent().append(copy);

      interest_category.prepend('<h5>'+$('input', interest_category)[0].value +'</h5>');
      $('input', interest_category).remove();

    }

    interest = (interest == undefined) ?  interest_category.children('h5').text() : interest;

    $.ajax({
      url: '/book/interest',
      type: 'POST',
      data: {isbn: $('#isbn').text(), interest: interest, },
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
    var interest = $(this).parents('.interest-category').children('.interest-name').value;
    interest = (interest == undefined) ?  $(this).parents('.interest-category').children('h5').text() : interest;
    $.ajax({
      url: '/book/interest',
      type: 'DELETE',
      data: {isbn: $('#isbn').text(), interest: interest, },
    })
    .done(function() {
      console.log("done");
    })
    .fail(function() {
      console.log("error");
    })
    .always(function() {
      console.log("complete");
    });
    $( '.add-interest', $($(this).parent()) ).removeClass('hidden');
    $(this).addClass('hidden');
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
    $('.form-control-static.editable', '.meetup-info').each(function(){
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

  $('.city-id-to-name').each( function(){
    $(this).text( get_city($(this).attr('data-id')).name );
  });

  var cities = [];
  if(get_at() != null) {
    var locations = get_at()
    $.each(locations, function(index, val) {
      cities.push(get_city(val));
    });
  } 

  // Create auto-complete input for city-search
  var city_input = $('#city-input').tokenInput("/city/auto/", 
                                               {prePopulate: cities,
                                                addTokenTo: '.city-search',
                                                onAdd: function(){  window.location.replace(get_fresh_link()) },
                                                onDelete: function(){ window.location.replace(get_fresh_link()) }});

  var bookinput = $('#book-input').tokenInput("/autocomplete/", {
      addTokenTo: '.search-box',
      propertyToSearch: "title",
      onPopulated: function() {
        // smooth_load()
      },
      resultsFormatter: function(item) {
                            return item.html_content;},
      tokenFormatter: function(item) { return item.html_content; },
      onAdd: function(item) {  }
  });
})