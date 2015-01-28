$(document).ready(function() {
  var slider = $('#site-main-image'),
      sliderHero = $('#site-hero-image'),
      sliderList = $('.site-gallery-list'),
      sliderItem = $('.site-gallery-list-item'),
      sliderNavLeft = $('.site-gallery-nav.left'),
      sliderNavRight = $('.site-gallery-nav.right'),
      slidesNum = sliderList.find('li').length;

  sliderItem.on('click', function(event){
    if ($(this).hasClass('selected')) {
      event.preventDefault();
    } else {
      $(this).addClass('selected').siblings().removeClass('selected');
      var localUrl = $(this).find("img").attr('src');
      sliderHero.attr("src",localUrl);
      lastSlide();
    }
  });

  sliderNavLeft.on('click', function(){
    var activeSlider = $('.site-gallery-list-item.selected');
    var activeSliderID = activeSlider.data('id');

    if (activeSliderID > 1) {
      var localUrl = sliderList.find("[data-id='" + (activeSliderID-1) + "']").find("img").attr('src');
      activeSlider.removeClass('selected');
      sliderList.find("[data-id='" + (activeSliderID-1) + "']").addClass('selected');
      sliderHero.attr("src",localUrl);
      sliderNavRight.removeClass('last');
      lastSlide();
    }
  });

  sliderNavRight.on('click', function(){
    var activeSlider = $('.site-gallery-list-item.selected');
    var activeSliderID = activeSlider.data('id');
    
    if (activeSliderID < slidesNum) {
      var localUrl = sliderList.find("[data-id='" + (activeSliderID+1) + "']").find("img").attr('src');
      activeSlider.removeClass('selected');
      sliderList.find("[data-id='" + (activeSliderID+1) + "']").addClass('selected');
      sliderHero.attr("src",localUrl);
      sliderNavLeft.removeClass('last');
      lastSlide();
    }
  });

  function lastSlide() {

    var activeSlider = $('.site-gallery-list-item.selected');
    var activeSliderID = activeSlider.data('id');

    if (activeSliderID == 1) {
      sliderNavLeft.addClass('last');
      sliderNavRight.removeClass('last');
    }
    if (activeSliderID == slidesNum) {
      sliderNavRight.addClass('last');
      sliderNavLeft.removeClass('last');
    } 
    if (activeSliderID < slidesNum && activeSliderID > 1) {
      sliderNavLeft.removeClass('last');
      sliderNavRight.removeClass('last');
    }
  }

});