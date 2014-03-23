$(function() {

  window.fbAsyncInit = function() {
   FB.init({
     appId      : '609765839077999',
	  status     : true, // check login status
	  cookie     : true, // enable cookies to allow the server to access the session
	  xfbml      : true  // parse XFBML
	});
 };

// Load the SDK asynchronously
(function(d){
	var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
	if (d.getElementById(id)) {return;}
	js = d.createElement('script'); js.id = id; js.async = true;
	js.src = "//connect.facebook.net/en_US/all.js";
	ref.parentNode.insertBefore(js, ref);
}(document));

$(function() {
	$('.btn-fb').click(function(e) {
   e.preventDefault();

   FB.login(function(response) {
     if (response.authResponse) {
      window.location.replace("/auth/facebook/callback");

	      // since we have cookies enabled, this request will allow omniauth to parse
	      // out the auth code from the signed request in the fbsr_XXX cookie
	      // $.getJSON('/auth/facebook/callback', function(json) {
	      //   	console.log('redirecting..');
	      //   	window.location.replace("/auth/facebook/callback");
	      // });
 }
}, { scope: 'email, user_location' });
 });
});


Storage.prototype.setObject = function(key, value) {
    this.setItem(key, JSON.stringify(value));
}

Storage.prototype.getObject = function(key) {
    var value = this.getItem(key);
    return value && JSON.parse(value);
}



});

function get_city(id){
  var city_history = localStorage.getObject('locations');
  var result;
  if (city_history != undefined || city_history != null) {
      $.each(city_history, function(index, val) {
         if (val.id.toString() == id) { result = val; };
      });
  }
  if (result != undefined) return result;
  return $.ajax({
      async: false,  
      url: '/city/id/' + id,
      success: function(loc){ 
        console.log('had to lookup loc');
        update_session_locations(loc);
        return loc;
      }
  }).responseJSON;
}

function update_session_locations(location) {
  var result;
  if (typeof location !== 'undefined' || location != null) {
    var location_history = merge_arrays(localStorage.getObject('locations'), [ location ]);
    localStorage.setObject('locations', location_history);
    result = location;
  } else {
    var locations = $('#city-input').tokenInput('get');
    var location_history = merge_arrays(localStorage.getObject('locations'), locations);
    localStorage.setObject('locations', location_history);
    result = locations;
  }
  $.ajax({
    url: '/locations/update',
    type: 'POST',
    data: {locations: JSON.stringify(result)},
  })
  .fail(function() {
    console.log("failed to update session locations");
  })
}

function merge_options(obj1,obj2){
    var obj3 = {};
    for (var attrname in obj1) { obj3[attrname] = obj1[attrname]; }
    for (var attrname in obj2) { obj3[attrname] = obj2[attrname]; }
    return obj3;
}

function merge_arrays(array1, array2) {
    var array;
    if (array1 == null) { array = array2 } else {
      var array = array1.concat(array2);
    }
    var a = array.concat();
    for(var i=0; i<a.length; ++i) {
        for(var j=i+1; j<a.length; ++j) {
            if(a[i] === a[j])
                a.splice(j--, 1);
        }
    }

    return a;
};

function get_at() {
  var urlArray = location.pathname.split('/');
  var newUrlArray = [];
  for (var i = 0; i < urlArray.length; i++) {
    var v  = urlArray[i];
    var v1 = urlArray[i+1];
    if (v == 'at') {
      return v1.split('+');
    }
  };
  return null;
}

function get_for() {
  var urlArray = location.pathname.split('/');
  var newUrlArray = [];
  for (var i = 0; i < urlArray.length; i++) {
    var v  = urlArray[i];
    var v1 = urlArray[i+1];
    if (v == 'for') {
      return v1;
    }
  };
  return null;
}

function get_fresh_link() {
  var urlArray = location.pathname.split('/');
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
  return newUrlArray.join(' ').split(/\s+/).join('/');
}

function getFormData($form){
  var unindexed_array = $form.serializeArray();
  var indexed_array = {};

  $.map(unindexed_array, function(n, i){
      indexed_array[n['name']] = n['value'];
  });
  return indexed_array;
}