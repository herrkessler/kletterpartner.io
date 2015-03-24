var ws_uri = location.href.replace(/^http/, 'ws');
var ws = new WebSocket(ws_uri);
ws.onopen = function() {
  console.log('WebSocket opened');
};
ws.onmessage = function(msg) {
  console.log(msg);
};
ws.onclose = function() {
  console.log('WebSocket closed');
};