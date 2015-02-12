$(document).ready(function() {

  initialScrollMessageBottom();

  // Setup - initial
  // -------------------------------

  var pusher = new Pusher('5d1b84365243a919e503'),
      firstConversation = $('.conversations-list-item:first-child').addClass('selected'),
      conversationID = $('.conversations-list-item.selected').data('id'),
      userID = $('#conversations').data('id'),
      conversationLink = $('.conversations-list-item'),
      messagesList = $('.messages-list'),
      message = $('#messages'),
      messageSpinner = $('#message-spinner'),
      deleteConvButton = $('#delete-conversation-link');

  // Set all channels
  // -------------------------------

  var channels = [];
  conversationLink.each(function(){
    channels.push($(this).data('id'));
  });
  channels.forEach(function(value, index){
    window['channel_'+value] = pusher.subscribe('conversation_'+value);
  });

  // Ajax Spinner stuff
  // -------------------------------
  
  $(document).ajaxStart(function() {
    messageSpinner.addClass('loading');
  });
  $(document).ajaxComplete(function() {
    setTimeout(function() {
      messageSpinner.removeClass('loading');
    }, 500);
  });

  // Change Conversation
  // -------------------------------

  conversationLink.on('click', function(){
    var messageId = $(this).data('id');
    $(this).addClass('selected');
    $(this).removeClass('new-message');
    $(this).siblings().removeClass('selected');
    message.attr('data-id', messageId);
    getMessages(userID, messageId);

    $.ajax({
      url: "/users/"+userID+"/conversation/"+messageId,
      dataType: 'json',
      contentType: 'application/json',
      type: 'GET',
      accepts: "application/json"
    });

  });
  

  // Pusher Bindings
  // -------------------------------

  pusher.bind('new_message', function(data) {
    $('.new_message').val('');
    if ($('.conversations-list-item.selected').data('id') == data.conversation) {
      $('.messages-list').append("<li class='messages-list-item'><div class='message-header'><div class='message-user user_"+data.sender+"'></div></div><div class='message-content'><div class='message-date message-timestamp'>"+data.timestamp+"</div><div class='message-text'>" + data.message + "</div></div</li>");
      scrollMessageBottom();
    } else {
      $(".conversations-list-item.conversation_"+ data.conversation).addClass('new-message');
    }
  });

  // Answer Message
  // -------------------------------

  $("#message-answer").submit(function(e) {
      e.preventDefault();
      var selectedConversation = $('.conversations-list-item.selected').data('id');
      if ($('.new_message').val().length === 0) {
        $('.new_message').focus();
      } else {
        $.post(window.location.origin +'/users/'+userID+'/messages/'+selectedConversation, $(this).serialize(), function() {
        });
      }
  });

  // New Message
  // -------------------------------

  var newMessageLink = $('#new-message');
  var overlay = $('#overlay');
  var sendNewMessageLink = $('#send-message');
  var closeOverlayLink = $('#close-overlay');

  // Close Overlay

  closeOverlayLink.on('click', function(){
    overlay.removeClass('active');
  });

  $(document).keyup(function(e) {
    if (e.keyCode == 27) {
      overlay.removeClass('active');
    } 
  });

  // Open Overlay

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
        url: "/users/"+userID+"/new-message/"+recieverId,
        dataType: 'json',
        contentType: 'application/json',
        type: 'POST',
        data : messageText,
        accepts: "application/json",
        success: function(json) {
          overlay.removeClass('active');
          getMessages(userID, json);
          var username = $('#new-message-reciever select option:selected').text();
          startNewConversation(json, username);
          $('#new-message-text textarea').val('');
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

    $.ajax({
      url: "/conversation/"+selectedConversation+"/delete",
      dataType: 'json',
      contentType: 'application/json',
      type: 'GET',
      accepts: "application/json",
      success: function(json) {
        deleteConversation(selectedConversation);
      }, 
      error: function(json) {
        console.log(json);
      }
    });

  });

  // Functions
  // -------------------------------

  function getMessages(userID, messageID) {
    $.getJSON( "/users/"+userID+"/messages/"+messageID, {
    }).done(function( data ) {
      $('.messages-list-item').remove();
      $.each(data, function(index, message){
        messagesList.append(
          '<li class="messages-list-item message_'+index+'"><div class="message-header"><div class="message-user user_'+message.sender+'"></div></div><div class="message-content"><div class="message-date message-timestamp">'+sqlTimetoDate(message.created_at)+'</div><div class="message-text">'+message.content+'</div></div></li>'
        );
        scrollMessageBottom();
      });
    });
  }

  function initialScrollMessageBottom() {
    $("#messages").scrollTop($(".messages-list").height());
  }

  function scrollMessageBottom() {
    $("#messages").scrollTop($(".messages-list").height() + $(".messages-list-item:last-child").height());
  }

  function sqlTimetoDate(date) {
    var t = date.split(/[- : T +]/);
    var d = new Date(t[0], t[1], t[2], t[3], t[4], t[5]);
    return d.toLocaleTimeString();
  }

  function startNewConversation(data, user) {
    $('.conversations-list-item').removeClass('selected');
    $('.conversations').prepend(
      '<li class="conversations-list-item conversation_'+data+' selected" data-id="'+data+'"><div class="conversation-inner-wrapper"><i class="fa fa-circle-o conversation-status green"></i><b>'+user+'</b><div class="conversation-timestamp">'+new Date().toLocaleTimeString()+'</div></div></li>'
      );
  }

  function deleteConversation(id) {
    $('.conversation_'+id).remove();
    $('.conversations-list-item').first().addClass('selected');
    var nextMessage = $('.conversations-list-item').first().attr('data-id');
    getMessages(userID, nextMessage);
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
});