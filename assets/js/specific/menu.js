$(document).ready(function(){
  var mobileMenuIcon = $('#mobile-navigation-icon'),
      mobileMenu = $('#mobile-navigation');

  mobileMenuIcon.on('click', function(){
    if (mobileMenu.hasClass('js-active')) {
      mobileMenu.removeClass('js-active');
      mobileMenuIcon.removeClass('js-active');
    } else {
      mobileMenu.addClass('js-active');
      mobileMenuIcon.addClass('js-active');
    }
  });
});