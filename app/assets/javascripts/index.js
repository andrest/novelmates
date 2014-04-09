$(function(){
  // Wire up book-input
  // $( "#book-input" ).on('input', book_input() ); 

  // Get location from GeoIP
  if ($.cookie('city_ip') == undefined) {
    $.ajax('/geoip').done(function(city){ 
      cookie_value = JSON.stringify({id: city[0].id, name: city[0].name});
      $.cookie('city_ip', cookie_value, { expires: 7, path: '/' });
      // $('body').trigger('auto_location');
    });
  }
  // Create auto-complete input for city-search
  var city_input = $('#city-input').tokenInput("/city/auto/", 
                                               {addTokenTo: '.city-search',
                                                preventDuplicates: true,
                                                onAdd: function(){ update_session_locations(); refresh_book_links() },
                                                onDelete: function(){ refresh_book_links() }});

  var bookinput = $('#book-input').tokenInput("/autocomplete/", {
      addTokenTo: '.search-box',
      propertyToSearch: "title",
      preventDuplicates: true,
      onClickDropdown: function(item) {
        if (item == undefined) item = $(this); //$(event.target).closest("li");
        document.location.href = $(item.children('a')[0]).attr('href')
      },
      onPopulated: function() {
        refresh_book_links();
        smooth_load();
      },
      resultsFormatter: function(item) {
                            return item.html_content;},
      tokenFormatter: function(item) { return item.html_content; },
      onAdd: function(item) { smooth_load(); refresh_book_links(); }
  });
  

  // Fill location automatically
  $('body').on('auto_location', function(){
    prefill_city(city_input);
    // Initalise the background mosaic
    init_gallery();
    // refresh_book_links();
  });
  
  // Try to determine locations
  determine_location();


});

// function get_location(){
//   if ($.cookie('city_coords') != undefined) return $.cookie('city_coords')
//   else if ($.cookie('city_ip') != undefined ) return $.cookie('city_ip')  
// }

$(function(){
  $('#book-search').on('search_results', function(){
    refresh_book_links('#book-search a.book-link');
  })
});

function refresh_book_links(urls) {
  urls = typeof urls !== 'undefined' ? urls : '.book-link';

  $(urls).each(function(index, link) {
    var urlArray = link.pathname.split('/');
    var newUrlArray = [];
    for (var i = 0; i < urlArray.length; i++) {
      var locations = $('#city-input').tokenInput('get');
      var v  = urlArray[i];
      var v1 = urlArray[i+1];
      newUrlArray.push(v);
      if (v == 'meetups' && v1 != 'at' && locations.length > 0) {
        newUrlArray.push('at');
        newUrlArray.push(locations.map(function(elem) {
                            return elem.id
                          }).join('+'));
      } else if (v == 'at') {
        newUrlArray.push(locations.map(function(elem) {
                            return elem.id
                          }).join('+'));
        i++;
      }
    };

    $(link).attr('href', newUrlArray.join(' ').split(/\s+/).join('/'));
    // var newUrlArray = [urlArray[0], urlArray[1]];
    // newUrlArray.push( $('#city-input').tokenInput('get').map(function(elem) {
    //   return elem.id
    // }).join('+'););
    // $.each(urlArray, function(i){ newUrlArray.push(i) }
    // $(link).attr('href', urlArray.join(' ').split(/\s+/).join('/'));
    // $(link).on('click', function() {
    //   // $(link).attr('href', urlArray.join('/'));
    // });
  });
}

function init_gallery(location) {
  $.ajax({
    url: '/mosaic/'+$('#city-input').tokenInput('get')[0].id
  })
  .done(function(mosaic) {
    // Remove the extra tiles from the end
    $($.parseHTML(mosaic)).appendTo('#wrapper');
    var remove_count = 0;
    if ($(document).width() >= 992) {
      remove_count = $('a', ".gallery").length % 3
    }
    else if ($(document).width() >= 768) {
      remove_count = $('a', ".gallery").length % 2
    }

    for(var i = 0; i <  remove_count;  i++) {
      $('a:last-child', ".gallery").remove();
    }

    $('.gallery img').load(function() {
      var container = document.querySelector('.gallery');
      var msnry = new Masonry( container, {
        // options
        "gutter": 40,
        itemSelector: '.cover-container',
        "isFitWidth": true,
        columnWidth: 250
      }); 
    });
    refresh_book_links('.gallery a.book-link');
  })
  .fail(function() {
    console.log("error getting the mosaic");
  });
}

function loc_from_coords(latS, lngS) {
  var loc = 'none';
  var lat = parseFloat(latS);
  var lng = parseFloat(lngS);
  var geocoder = new google.maps.Geocoder();
  var latlng = new google.maps.LatLng(lat, lng);

  function geocode_handler(results, status) {
  if (status == google.maps.GeocoderStatus.OK) {
      if (results[1]) {
        var address = results[0].address_components;
        var country, city;
        console.log(results[0].formatted_address);
        
        $.each(address, function(i, component){
          
          if (component.types[0] == "country"){
            country = component.long_name;
          }
          if (component.types[0] == "postal_town"){
            city = component.long_name;
          }
        });
        loc = city+", "+country;
        get_geonames_id(loc);
        // cookie_value = JSON.stringify({id: 0, name: city+', '+country});
        // JSON.stringify('{"id": 0, "name": "'city+', '+country+'"}');

        // $.cookie('city_coords', cookie_value, { expires: 30, path: '/' });
        // return address;
      }
    } else {
      alert("Geocoder failed due to: " + status);
    }
  }

  geocoder.geocode({'latLng': latlng}, geocode_handler);
}

function get_geonames_id(address){
  $.ajax({
    url: '/geo/'+address
  })
  .done(function(city) {
    cookie_value = JSON.stringify({id: city[0].id, name: city[0].name});
    $.cookie('city_coords', cookie_value, { expires: 30, path: '/' });

    $('body').trigger('auto_location');
  })
  .fail(function() {
    console.log("error");
  })
  .always(function() {
    console.log("complete");
  });
  
}

function determine_location() {
  if (!Modernizr.geolocation && $.cookie('city_ip') != undefined) {
    $('body').trigger('auto_location');
    return;
  }
  else if (!navigator.geolocation || $.cookie('city_coords') != undefined) {
    $('body').trigger('auto_location');
    return;
  }
  console.log('going to determine coords location now')

  function success(position) {
    var latitude  = position.coords.latitude;
    var longitude = position.coords.longitude;

    loc_from_coords(latitude, longitude);
    // add function to convert all mosaic links to right
    // refresh_book_links();
    // callback();
  };

  function error(error) {
    if ($.cookie('city_ip') != undefined) {
      $('body').trigger('auto_location');
    }
    console.log("Unable to retrieve your coordinate location: "+error.message);
  };

  navigator.geolocation.getCurrentPosition(success,error,{timeout:10000});

}

function exists_city(id){
  var locations = $('#city-input').tokenInput("get");
  var ids = locations.map(function(elem) {
           return elem.id
  });
  return $.inArray(id, ids) > -1;
}

function prefill_city(input){
  if ($.cookie('city_coords') != undefined) {
    var city_coords = JSON.parse( $.cookie('city_coords') );
    console.log(city_coords);
    if (!exists_city(city_coords.id)) {
      input.tokenInput("add", {id: city_coords.id, name: city_coords.name });
    }
  }
  if ($.cookie('city_ip') != undefined) {
    var city_ip = JSON.parse($.cookie('city_ip'));
    if (!exists_city(city_ip.id)) {
      input.tokenInput("add", {id: city_ip.id, name: city_ip.name});
    }
  } 
}

var spinner;
var opts = {
  lines: 9, // The number of lines to draw
  length: 3, // The length of each line
  width: 2, // The line thickness
  radius: 4, // The radius of the inner circle
  corners: 0.2, // Corner roundness (0..1)
  rotate: 0, // The rotation offset
  direction: 1, // 1: clockwise, -1: counterclockwise
  color: '#000', // #rgb or #rrggbb or array of colors
  speed: 1.1, // Rounds per second
  trail: 60, // Afterglow percentage
  shadow: false, // Whether to render a shadow
  hwaccel: false, // Whether to use hardware acceleration
  className: 'spinner', // The CSS class to assign to the spinner
  zIndex: 2e9, // The z-index (defaults to 2000000000)
  top: 11, // Top position relative to parent in px
  left: -28 // Left position relative to parent in px
};

spinner = new Spinner(opts).spin();

function book_input(e) {

  var lastParam       = "";
  var timerId         = -1;
  var request;
  var lastRequestMade = 0;
  var lastRequest;
  
  return function(e) {
    var param = $(e.target).val();
    if (param.length <= 3) return;
    // param = stripJunk(param);
    if (param.length <= 3) return;

    if (param.length - param.lastIndexOf(" ") -1 <= 3) return;    

    if (lastParam == param) return; 
    else lastParam = param;

    setRequest({
      url: "/autocomplete/" + $(e.target).val(),
      dataType: "text",
      success: function( data ) {
        spinner.stop();
        response(data);
      } 
    });


    function setRequest(req) {
      request = req;
      var currentTime = new Date().getTime();
      if (lastRequestMade == 0) makeRequest();
      else if (currentTime - lastRequestMade >= 1000) makeRequest();
      else if (timerId == -1) timerId = window.setTimeout(makeRequest, 1000 - (currentTime - lastRequestMade));
    }

    function makeRequest() {
      if (lastRequest != undefined) { 
        lastRequest.abort();
        console.log("aaaabort");
      }
      lastRequestMade = new Date().getTime();
      timerId = -1;
      
      var target = document.getElementById('spinner');
      spinner.spin(target);
      lastRequest = $.ajax(request);
    }


    function response(items) {
      if (items.length == 0) return;
      $("#books").empty();
      $("#books").append(items)

      $("#books li:even").css("background-color","rgba(235,241,241,0.7)"); 
      $("#books li:odd").css("background-color","rgba(239, 247, 247, 0.7");
      //$(".gallery").addClass("blur");

      $('img.book-cover').on('load', function(){
        $(this).fadeIn(200);
        $(this).removeClass('hidden');
      });
      console.log(this);
      $('#book-search').trigger('search_results');
    }
  }
}




