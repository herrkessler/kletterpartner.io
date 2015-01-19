$(document).ready(function() {

  if ($('body').hasClass('logged-in')) {
    $(function() {
      
      $( document ).idleTimer( {
        timeout: 300000, 
        idle: true
      });

      $( document ).on( "idle.idleTimer", function(event, elem, obj){
        $.ajax({
          url: "/user/idle",
          dataType: 'json',
          contentType: 'application/json',
          type: 'GET',
          accepts: "application/json"
        });
      });

      $( document ).on( "active.idleTimer", function(event, elem, obj, triggerevent){
        $.ajax({
          url: "/user/online",
          dataType: 'json',
          contentType: 'application/json',
          type: 'GET',
          accepts: "application/json"
        });
      });
    });
  }
});