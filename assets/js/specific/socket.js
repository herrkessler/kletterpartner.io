// $(document).ready(function(){

//   var ws = new WebSocket('ws://' + window.location.host + window.location.pathname);

//   ws.onopen = function() {
//     console.log('websocket opened');
//   };
//   ws.onclose = function() {
//     console.log('websocket closed');
//   };
//   ws.onmessage = function(m) {
//     console.log('Message: '+m.data);
//   };

// });

$(document).ready(function() {
  var pusher = new Pusher('5d1b84365243a919e503');
  var channel = pusher.subscribe('test_channel');
  channel.bind('new_message', function(data) {
    $('.messages').append("<div class=\"message\">" + data.message + "</div>");
  });
  // Pusher.log = function(message) {
  //   if (window.console && window.console.log) window.console.log(message);
  // };
  $("#message_form").submit(function(e) {
      e.preventDefault();
      $.post('/messages', $(this).serialize(), function() {
          $("#message_form input").val('');
      });
  });
});