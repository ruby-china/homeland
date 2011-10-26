//= require jquery
//= require jquery_ujs
//= require bootstrap-alerts
//= require bootstrap-dropdown
//= require bootstrap-twipsy
//= require jquery.jdialog
//= require jquery.timeago
//= require_self
$(document).ready(function() {
  $("abbr.timeago").timeago();
  $(".alert-message").alert();
	$("a[rel=twipsy]").twipsy({ live: true });
});
