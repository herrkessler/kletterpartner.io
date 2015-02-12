$(document).ready(function(){

  var pusher = new Pusher('5d1b84365243a919e503');
  var userID = $('body').data('id');

  pusher.subscribe('realtime');

  pusher.bind('new_message', function(data) {
    var mailCounter = $('#mail').find('.mail-counter');
    var mobileMailCounter = $('#mobile-mail').find('.mail-counter');
    if (data.sender !== userID) {
      if (mailCounter.length > 0) {
        var initialCounterValue = mailCounter.text();
        var newCounterValue = parseInt(initialCounterValue);
        mailCounter.text(newCounterValue+1);
        mobileMailCounter.text(newCounterValue+1);
      } else {
        $('#mail a').append('<span class="mail-counter">1</span>');
        $('#mobile-mail a').append('<span class="mail-counter">1</span>');
      }
    }
  });
});