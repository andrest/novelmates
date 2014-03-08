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






});