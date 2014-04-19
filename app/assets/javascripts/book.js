$(function(){
  // Initalise tokenInput fields (city input and book input)
  var cities = [];
  if(get_at() != null) {
    var locations = get_at()
    $.each(locations, function(index, val) {
      cities.push(get_city(val));
    });
  }
  var books = [];
  $('.book-data').each(function() { 
    var book = $(this).data('book')[0];
    book.html_content = book.html_content.replace('hidden', '');
    // book.html_content = "<li>"+book.title+"</li>";
    books.push(book); 
  });
  // if(get_for() != null) {
  //   var books = get_for()
  //   $.each(books, function(index, val) {
  //     books.push(get_book(val));
  //   });
  // }
  // Create auto-complete input for city-search

  var city_input = $('#city-input').tokenInput("/city/auto/", 
                                               {prePopulate: cities,
                                                addTokenTo: '.city-search',
                                                onAdd: function(){  window.location.replace(get_fresh_link()) },
                                                onDelete: function(){ window.location.replace(get_fresh_link()) }});

  var bookinput = $('#book-input').tokenInput("/autocomplete/", {
      prePopulate: books,
      addTokenTo: '.search-box',
      propertyToSearch: "title",
      onPopulated: function() {
        smooth_load()
      },
      onAdd: function(){ window.location.replace(get_fresh_link()) },
      onDelete: function(){ window.location.replace(get_fresh_link()) },
      tokenLimit: 3,
      resultsFormatter: function(item) {
                            return item.html_content;},
      tokenFormatter: function(item) { return item.html_content; }
  });

  $('.new-meetup-btn').on('click', function() {
    var parent = $(this).parent("div");
    parent.find('.list-group').first().addClass('hidden');
    parent.find('.new-meetup').first().removeClass('hidden');
    $(this).addClass('hidden');
  });
  $('.new-meetup button.close').on('click', function() {
    var parent = $(this).parent().parent();
    parent.find('.list-group').first().removeClass('hidden');
    parent.find('.new-meetup').first().addClass('hidden');
    parent.find('.new-meetup-btn').first().removeClass('hidden');
  });

  function book_for(selector) {
    var element; 
    if ($(selector).hasClass('.book-listing')) { element = $(selector) }
    else element = $(selector).parents('.book-listing');

    if (element == undefined || element.length == 0) {
      return {id: $('#isbn').text()};
    } else {
      return element.find('.book-data').data('book')[0];
    }
  }

  var add_interest_handler = function() {
    var interest_category = $(this).parents('.interest-category');
    var interest = interest_category.children('.interest-name')[0].value;
    if (interest != undefined) {
      if (interest == "") {
        return;
      }
      var copy = interest_category.clone()
      $('.add-interest', copy).on('click', function(){ add_interest_handler.call(this); });
      $('.remove-interest', copy).on('click', function(){ remove_interest_handler.call(this); });
      $('input', copy)[0].value = "";
      $(interest_category).parent().append(copy);

      interest_category.prepend('<h5 class="interest-name">'+$('input', interest_category)[0].value +'</h5>');
      $('input', interest_category).remove();
    }

    interest = (interest == undefined) ?  interest_category.children('h5').text() : interest;

    $.ajax({
      url: '/book/interest',
      type: 'POST',
      data: {isbn: book_for(this).id, interest: interest, },
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
  }
  var remove_interest_handler = function() {
    var interest = $(this).parents('.interest-category').children('.interest-name').value;
    interest = (interest == undefined) ?  $(this).parents('.interest-category').children('h5').text() : interest;
    $.ajax({
      url: '/book/interest',
      type: 'DELETE',
      data: {isbn: book_for(this).id, interest: interest, },
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
  }

  $('.add-interest').on('click', function() {
    add_interest_handler.call(this);
  });

  $('.remove-interest').on('click', function() {
    remove_interest_handler.call(this);
  });

  $('.pull-right.people').on('click', function(e) {
    e.stopPropagation();
  });


  $('.city-id-to-name').each( function(){
    $(this).text( get_city($(this).attr('data-id')).name );
  });

})