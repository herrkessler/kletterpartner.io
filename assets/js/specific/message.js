$(document).ready(function(){

  // Settings
  // -------------------------------
  var message = $('#messages'),
      firstConversation = $('#conversations-list li').first(),
      conversationId = $('#conversations-list li').first().data('id'),
      userId = $('#conversations').data('id'),
      messagesList = $('.messages-list'),
      messageSpinner = $('#message-spinner'),
      conversationLink = $('.conversations-list-item'),
      answerText = $('#message-answer'),
      answerLink = $('#message-answer-link'),
      view = window.location.href;

  // Get Messages
  // -------------------------------

  firstConversation.addClass('selected');
  message.attr('data-id', conversationId);

  if(view.indexOf("messages") > -1) {
    getMessages(userId, conversationId);
  }
  
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
    message.attr('data-id', messageId);
    getMessages(userId, messageId);
  });

  answerLink.on('click', function(event){
    event.preventDefault();
    if (answerText.val().length === 0) {
      answerText.focus();
    } else {
      var messageText = answerText.val();
      var selectedConversation = $('#messages').attr('data-id');

      $.ajax({
        url: "/users/"+userId+"/messages/"+selectedConversation,
        dataType: 'json',
        contentType: 'application/json',
        type: 'POST',
        data : messageText,
        accepts: "application/json",
        success: function() {
          getMessages(userId, selectedConversation);
          answerText.val('');
        }, 
        error: function(json) {
          console.log(json);
        }
      });
    }
  });

  // New Message
  // -------------------------------

  var newMessageLink = $('#new-message');

  newMessageLink.on('click', function(event){
    event.preventDefault();
    var messageText = 'Static Text';
    var newConversation = '1';
    var recieverId = '4';

    $.ajax({
      url: "/users/"+userId+"/new-message/"+recieverId,
      dataType: 'json',
      contentType: 'application/json',
      type: 'POST',
      data : messageText,
      accepts: "application/json",
      success: function() {
        getMessages(userId, selectedConversation);
        console.log(json);
      }, 
      error: function(json) {
        console.log(json);
      }
    });
  });

  // Functions
  // -------------------------------

  function scrollMessageBottom() {
    $("#messages").scrollTop($(".messages-list-item:last-child").position().top);
  }

  function getMessages(userID, messageID) {
    $.getJSON( "/users/"+userID+"/messages/"+messageID, {
    }).done(function( data ) {
      console.log(data[0]);
      $('.messages-list-item').remove();
      $.each(data[1], function(index, message){
        messagesList.append(
          '<li class="messages-list-item message_'+index+'"><div class="message-header"><div class="message-date message-timestamp">'+message.created_at+'</div></div><div class="message-content">'+message.content+'</div></li>'
        );
        scrollMessageBottom();
      });
    });
  }

});