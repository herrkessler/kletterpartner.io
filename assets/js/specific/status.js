$(document).ready(function() {
  var pusher = new Pusher('5d1b84365243a919e503');
  var channel = pusher.subscribe('online_users');
  var channel_2 = pusher.subscribe('user_status');

  channel.bind('status', function(data) {
    var users = data.message;
    $('.user').find('.card-online-indicator').removeClass('online').addClass('offline');
    for (var i = 0; i < users.length; i++) {
      $('.user_'+users[i]).find('.card-online-indicator').removeClass('offline idle').addClass('online');
    }
  });

  channel_2.bind('status', function(data) {
    if (data.status == 'idle') {
      $('.user_'+data.user).find('.card-online-indicator').removeClass('online').addClass('idle');
    } else {
      $('.user_'+data.user).find('.card-online-indicator').removeClass('idle').addClass('online');
    }
  });

});