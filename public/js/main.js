
$(function() {		

var lastParam       = "";
var timerId         = -1;
var request;
var lastRequestMade = 0;
var lastRequest;

function determine_location() {
  var output = document.getElementById("out");

  if (!navigator.geolocation) return;

  function success(position) {
    var latitude  = position.coords.latitude;
    var longitude = position.coords.longitude;

    output.innerHTML = '<p>Latitude is ' + latitude + '° <br>Longitude is ' + longitude + '°</p>';

    var img = new Image();
    img.src = "http://maps.googleapis.com/maps/api/staticmap?center=" + latitude + "," + longitude + "&zoom=13&size=300x300&sensor=false";

    output.appendChild(img);
  };

  function error() {
    output.innerHTML = "Unable to retrieve your location";
  };

  output.innerHTML = "<p>Locating…</p>";

  navigator.geolocation.getCurrentPosition(success, error);
}

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
  top: 8, // Top position relative to parent in px
  left: -24 // Left position relative to parent in px
};

spinner = new Spinner(opts).spin();

$( "#book-input" ).on('input',function(e) {
	var param = $(this).val();
	if (param.length <= 3) return;
	param = stripJunk(param);
	if (param.length <= 3) return;
	
	if (param.length - param.lastIndexOf(" ") -1 <= 3) return;		
	
	if (lastParam == param) return; 
	else lastParam = param;
	
	console.log(this);
	setRequest({
			url: "/autocomplete/" + $(this).val(),
			dataType: "text",
			success: function( data ) {
				spinner.stop();
				response(data);
				// xml = $.parseXML(data);

				// response( itemsToHTML(xml) );
        /*
        $('.gallery .book-cover').parent().hover(function(){
          $(this).find('.book-cover').addClass('flipped').parent().mouseleave(function(){
              $(this).find('.book-cover').removeClass('flipped');
          });
          return false;
        }); */
      
			}
		});
});



function sizing() {
  var input=$("#book-search").width();
  if ($("#book-search").width() >=  392) return;
  $("#book-input").width((input-85-20)+"px");
}

function itemsToHTML( xml ) {
	removeDuplicateBooks(	xml);
	
	var itemsInHTML = $.map( $(xml).find('Item') , function( item ) { return itemToHTML(item); } );
	
	return itemsInHTML;
}

function itemToHTML( item ) {
	return {
		value: $(item).find('Title').text(),
		label: "<li>"
				+"<div class=\"cover-wrapper\"><span class=\"helper\"></span><a href=\"/" +$(document).find("#city").val()+"/" +$(item).find('ISBN').text() +"/"+ stripTitle($(item).find('Title').text()) +"\"><img class=\"book-cover hidden\" src=" + $(item).find('URL').text() +"><a/></div>"
				+"<div class=\"book-description\">"
				+"<span class=\"book-title\">" + $(item).find('Title').text() + "</span>"
				+"Author: <span class=\"book-author\">" + bookAuthors($(item).find('Author')) + "</span>"
				+"ISBN: <p class=\"isbn\">" + $(item).find('ISBN').text() + "</p>"
				+"</div>"
				+"</li>"
	}
}

function removeDuplicateBooks(xml) {
	bookTitles = {};
	$(xml).find("Title").each( function (index, title) {
		title = title.textContent.toLowerCase();
		title = stripJunk(title);
		title = title.replace( /({.*}|\(.*\)|\[.*\])/g, '');
		title = title.replace( /([.*+?^=!:${}()|\[\]\/\\])|\s/g, '');
		if (bookTitles.hasOwnProperty(title)) { return true; } 
		bookTitles[title] = index;
		
	});
	uniqueBooks = [];
	for (var key in bookTitles) {
		uniqueBooks.push( bookTitles[key] );
	}
	$(xml).find("Item").each( function (index, item) {
		if ($.inArray(index, uniqueBooks) == -1) {
			console.log("Removing duplicate: " + $(item).find('Title').text());
			item.remove();
		}				
	});
}

function stripTitle(title) {
	var re = /\s*([.*+?^=!:;${}()|\[\]\/\\])/;
	title = title.split(re)[0].toLowerCase();
	return title.replace(/\W/g, "-");
}

function bookAuthors(authors) {
	var s = $(authors[0]).text();
	authors.each(function(i) {
		if (i > 0) {
			s = s.concat(", " + ($(this).text()) );
		}
	});
	return s;
}

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
	console.log(spinner.el);
	lastRequest = $.ajax(request);
}

function escapeRegExp(string){
	return string.replace(/\s*([.*+?^=!:${}()|\[\]\/\\])/gi, "\\$1");
}

function response(items) {
	if (items.length == 0) return;
	$("#books").empty();
	$("#books").append(items)
	
	// $(items).each(function() {
	// 	$("#books").append(this.label);
	// 	$("img", "#books li:last-child" ).load(function() {
	// 		$(this).fadeIn(200);
	// 		$(this).removeClass('hidden');
	// 	});
	// 	// var cover = $($.parseHTML(this.label.slice(4, -4))[0]).find('.book-cover')[0];
	// 	// $(cover).css("");
	// 	// console.log(cover.parentNode);
	// 	// $(cover.parentNode).append("<div class='back'></div>");
	// 	// $(".gallery").append(cover.parentNode);
	// 	}
	//  );
	$("#books li:even").css("background-color","rgba(235,241,241,0.7)"); 
	$("#books li:odd").css("background-color","rgba(247,251,253,0.7)");
	//$(".gallery").addClass("blur");

	$('#books li img').on('load', function(){
		$(this).fadeIn(200);
		$(this).removeClass('hidden');
	});
}




function stripJunk(s) {
	var suffix = ''
	if (s[s.length-1] == " ") suffix = ' ';
	var junk = [ "and", "or", "the", "a", "an", "of", "to" ];
	jQuery.each(junk, function() {
		var re = new RegExp("(^|\\s)" +this+"($|\\s)", 'gi');
		s = s.replace(re, " ");
	});
	while (s[s.length-1] == " ") s = s.substring(0, s.length-1);
	while (s[0] == " ") s = s.substring(1, s.length);
	return s+suffix;
}

function imageLoaded(i) {
	$(i).visible(true);
}

});