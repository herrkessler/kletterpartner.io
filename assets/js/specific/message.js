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
      view = window.location.href,
      deleteConvButton = $('#delete-conversation-link');

  // Get Messages
  // -------------------------------

  firstConversation.addClass('selected');
  message.attr('data-id', conversationId);

  if(view.indexOf("messages") > -1) {
    getMessages(userId, conversationId);

    $.ajax({
      url: "/users/"+userId+"/conversation/"+conversationId,
      dataType: 'json',
      contentType: 'application/json',
      type: 'GET',
      accepts: "application/json"
    });
    
  }
  
  $(document).ajaxStart(function() {
    messageSpinner.addClass('loading');
  });
  $(document).ajaxComplete(function() {
    messageSpinner.removeClass('loading');
  });

  conversationLink.on('click', function(){
    console.log('deleteConvButton');
    var messageId = $(this).data('id');
    $(this).addClass('selected');
    $(this).siblings('.conversations-list-item').removeClass('selected');
    message.attr('data-id', messageId);
    getMessages(userId, messageId);

    $.ajax({
      url: "/users/"+userId+"/conversation/"+messageId,
      dataType: 'json',
      contentType: 'application/json',
      type: 'GET',
      accepts: "application/json"
    });

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
  var overlay = $('#overlay');
  var sendNewMessageLink = $('#send-message');

  newMessageLink.on('click', function(event) {
    event.preventDefault();
    overlay.addClass('active');
    
  });

  sendNewMessageLink.on('click', function(event){
    event.preventDefault();
    var messageText = $('#new-message-text textarea').val();
    var recieverId = $('#new-message-reciever select option:selected').val();

    if (recieverId !== '' && messageText !== '') {
      $.ajax({
        url: "/users/"+userId+"/new-message/"+recieverId,
        dataType: 'json',
        contentType: 'application/json',
        type: 'POST',
        data : messageText,
        accepts: "application/json",
        success: function(json) {
          overlay.removeClass('active');
          getMessages(userId, json);
        }, 
        error: function(json) {
          console.log(json);
        }
      });
    } else {
      $('#new-message-text textarea').focus(); 
    }
    
  });

  // Delete Conversation
  // -------------------------------

  deleteConvButton.on('click', function(event){
    event.preventDefault();
    var selectedConversation = $('#messages').attr('data-id');
    console.log(selectedConversation);

    // $.ajax({
    //   url: "/conversation/"+selectedConversation+"/delete/",
    //   dataType: 'json',
    //   contentType: 'application/json',
    //   type: 'GET',
    //   accepts: "application/json",
    //   success: function(json) {
    //     deleteConversation(selectedConversation);
    //   }, 
    //   error: function(json) {
    //     console.log(json);
    //   }
    // });

  });

  // Functions
  // -------------------------------

  function scrollMessageBottom() {
    $("#messages").scrollTop($(".messages-list-item:last-child").position().top);
  }

  function getMessages(userID, messageID) {
    $.getJSON( "/users/"+userID+"/messages/"+messageID, {
    }).done(function( data ) {
      $('.messages-list-item').remove();
      $.each(data, function(index, message){
        messagesList.append(
          '<li class="messages-list-item message_'+index+'"><div class="message-header"><div class="message-user user_'+message.sender+'"></div></div><div class="message-content"><div class="message-date message-timestamp">'+message.created_at+'</div><div class="message-text">'+message.content+'</div></div></li>'
        );
        scrollMessageBottom();
      });
    });
  }

  function deleteConversation(id) {

  }

});

// Mobile view functions
// ------------------------------

$(document).ready(function(){

  var windowWidth = $(window).width();
  var switchLink = $('#show-menu-mobile');
  var textSpan = switchLink.find('span');
  var conversationLink = $('.conversations-list-item');
  var conversationWrapper = $('#conversations');
  var showInboxLink = $('#show-inbox');
  var messagAnswer = $('#message-answer-box');


  if (windowWidth < 480) {

    console.log(windowWidth);

    conversationLink.on('click', function(event){
      event.preventDefault();
      conversationWrapper.addClass('mobile-active');
      switchLink.addClass('active');
      textSpan.text('Eingang');
      messagAnswer.show();
    });

    
    switchLink.on('click', function(event){

      if (conversationWrapper.hasClass('mobile-active')) {
        event.preventDefault();
        conversationWrapper.removeClass('mobile-active');
        textSpan.text('Postfächer');
        $(this).removeClass('active');
        messagAnswer.hide();
      } else {
        event.preventDefault();
        $(this).hide();
        conversationWrapper.addClass('mobile-menu-active');
      }
    });

    showInboxLink.on('click', function(event) {
      event.preventDefault();
      conversationWrapper.removeClass('mobile-menu-active');
      switchLink.show();
    });

  }

  // else if (windowWidth < 768) {

  //   switchLink.on('click', function(event){
  //     event.preventDefault();
  //     conversationWrapper.addClass('tablet-active');
  //   });

  // }

});

