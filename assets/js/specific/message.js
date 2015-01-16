$(document).ready(function(){
  var message = $('#messages'),
      firstConversation = $('#conversations-list li').first(),
      conversationId = $('#conversations-list li').first().data('id'),
      userId = $('#conversations').data('id'),
      messagesList = $('.messages-list'),
      messageSpinner = $('#message-spinner');
      conversationLink = $('.conversations-list-item');

  firstConversation.addClass('selected');

  getMessages(userId, conversationId);
  
  $(document).ajaxStart(function() {
    messageSpinner.addClass('loading');
  });

  $(document).ajaxComplete(function() {
    messageSpinner.removeClass('loading');
  });

  conversationLink.on('click', function(){
    var messageId = $(this).data('id');
    $(this).addClass('selected');
    $(this).siblings('.conversations-list-item').removeClass('selected');
    getMessages(userId, messageId);
  });

  function getMessages(user, message) {
    $.getJSON( "/users/"+user+"/messages/"+message, {
    }).done(function( data ) {
      $('.messages-list-item').remove();
      $.each(data, function(index, message){
        messagesList.append(
          '<li class="messages-list-item message_'+index+'"><div class="message-header"><div class="message-title">'+message.title+'</div><div class="message-date message-timestamp">'+message.created_at+'</div></div><div class="message-content">'+message.content+'</div></li>'
          );
      });
    });
  }


});