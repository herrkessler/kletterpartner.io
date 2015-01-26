$(document).ready(function() {
  var pusher = new Pusher('5d1b84365243a919e503');
  var channel = pusher.subscribe('online_users');

  channel.bind('status', function(data) {
    console.log(data.message);
    var users = data.message;
    $('.user').find('.card-online-indicator').removeClass('online').addClass('offline');
    for (var i = 0; i < users.length; i++) {
      $('.user_'+users[i]).find('.card-online-indicator').removeClass('offline idle').addClass('online');
    }
  });

});