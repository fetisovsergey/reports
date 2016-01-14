// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require select2
//= require jquery_ujs
//= require bootstrap
//= require turbolinks
//= require fancybox
//= require mapbox.js
//= require_tree .
$(document).ready(function() {
    $(".image_post").fancybox({
		transitionIn: 'elastic',
		transitionOut: 'elastic',
		speedIn: 400,
		speedOut: 400,
    	padding: 0,
    	centerOnScroll: true,
    	cyclic: true
    });
    $(".image_gallery").fancybox({
    	transitionIn: 'elastic',
    	speedIn: 400,
    	padding: 0,
    	centerOnScroll: true,
    	cyclic: true
    });
    $("#recepients").select2({placeholder: "Введите имя пользователя..." });
});
