$(function(){
  var city_input = $('#city-input').tokenInput("/city/auto/");
  determine_location(function(){
    prefill_city(city_input);
  });

  init_gallery()
});

function init_gallery() {
  $.ajax({
    url: '/mosaic'
  })
  .done(function(mosaic) {
    //console.log($.parseHTML(mosaic)[1]);
    $($.parseHTML(mosaic)).appendTo('#wrapper');
    if ($(document).width() >= 1200) {
      $('a:last-child', ".gallery").remove();
      $('a:last-child', ".gallery").remove();
    }
    else if ($(document).width() >= 992) {
      $('a:last-child', ".gallery").remove();
    }
    else if ($(document).width() >= 768) {
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

  })
  .fail(function() {
    console.log("error getting the mosaic");
  });
}

function loc_from_coords(latS, lngS) {
  var lat = parseFloat(latS);
  var lng = parseFloat(lngS);
  var geocoder = new google.maps.Geocoder();
  var latlng = new google.maps.LatLng(lat, lng);
  geocoder.geocode({'latLng': latlng}, function(results, status) {
  if (status == google.maps.GeocoderStatus.OK) {
      if (results[1]) {
        var address = results[1].address_components;
        var country, city;

        $.each(address, function(i, component){
          
          if (component.types[0] == "country"){
            country = component.long_name;
          }
          if (component.types[0] == "postal_town"){
            city = component.long_name;
          }
        });

        $.cookie('city_coords', city+", "+country, { expires: 30, path: '/' });
        return address;
      }
    } else {
      alert("Geocoder failed due to: " + status);
    }
  });
}

function determine_location(callback) {
  if (!navigator.geolocation || $.cookie('city_coords') != undefined) callback();
  console.log('going to determine coords location now')

  function success(position) {
    var latitude  = position.coords.latitude;
    var longitude = position.coords.longitude;

    loc_from_coords(latitude, longitude);
    callback();
  };

  function error() {
    console.log("Unable to retrieve your location");
  };

  navigator.geolocation.getCurrentPosition(success, error);
}

function prefill_city(input){
  if ($.cookie('city_coords') != undefined) {
    input.tokenInput("add", {id: '0', name: $.cookie('city_coords')});
    return;
  }
  else if ($.cookie('city_ip') != undefined) {
    input.tokenInput("add", {id: '0', name: $.cookie('city_ip')});
  } 
}
