+"use strict";
exports = module.exports = function(server) {
  var WebSocket = require('websocket').w3cwebsocket;

  var lastReconnect = null;
  var serverWs;

  var wsMessage = (evt) => {
    if (evt.data.length > 0) {
      try {
        var msg = JSON.parse(evt.data);
        msg.data = typeof msg.data == 'number' ? msg.data+"" : msg.data;

        if (msg && msg.req) {
          let wsR = wsRequests[msg.req];
          if(wsR){
            for(var i=0; i<wsR.cb.length; i++){
              wsR.cb[i](null, null, msg.data);
            }
            delete wsRequests[msg.req];
            clearTimeout(wsR.timeout);
          }
        }

      } catch (e) {
        console.error("WS Invalid data: ", e);
      }
    }
  };


  var wsRequests = {};

  function wsRequest(path, cb) {
    if (!serverWs) {
      return cb("No WS");
    }
    if (wsRequests.hasOwnProperty(path)) {
      wsRequests[path].cb.push(cb);
      return;
    }

    wsRequests[path] = {
      cb: [cb],
      timeout: setTimeout(wstimeout, 10000, path)
    }

    try{
      serverWs.send(path);
    }catch(e){
      console.error("Error websocket: ", e);
    }
  }

  function wstimeout(path) {
    if (!wsRequests.hasOwnProperty(path)) {
      return;
    }
    var cbs = wsRequests[path].cb;
    for (var i = 0; i < cbs.length; i++) {
      cbs[i]("timeout");
    }
    delete wsRequests[path];
  }


  function reconnect() {
    if(lastReconnect && (new Date() - lastReconnect)/1000 > 4){
      return;
    }
    if (serverWs) {
      serverWs.onerror = () => { };
      serverWs.close();
      serverWs = null;
    }
    lastReconnect = new Date();
    console.log("Connecting to server websocket");
    serverWs = new WebSocket("ws://5.196.39.50:27016");
    serverWs.onerror = () => { setTimeout(reconnect, 4000) };
    serverWs.onmessage = wsMessage;
  };

  reconnect();

  server.wsRequest = wsRequest;
}
