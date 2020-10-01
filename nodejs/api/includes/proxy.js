"use strict";
exports = module.exports = function(server) {

var Rcon = require('rcon');
var proxy = require('dgram').createSocket('udp4');
var fs = require('fs');
var socket = require("socket.io");
var https = require('https');

var io = socket.listen( http.createServer().listen("127.0.0.1:4080") ); // Reverse proxy par nginx

io.sockets.on('connection', function (socket, msg) {
	var ip = socket.handshake.address;

    socket.on('auth', function (data) {

		server.conn.query(server.getAuthSMAdmin, [data.sso], function(err, row ){
			if( row[0] != null ) {
				socket.emit("data", "Bienvenue "+row[0].username+" :-)");
				socket.join("private_"+data.ip+":"+data.port);
			}
			else {
				socket.emit("data", "Connexion refusée.");
				socket.disconnect();
			}
		});
	});
});

proxy.on('message', function (message, from) {
    var chan = from.address+":"+from.port;

	var msg = message.toString('utf-8').slice(5,-1);
	if( msg.indexOf("[RIPLAY-RP] Loading userdata") == -1 ) {
		io.sockets.to("private_"+chan).emit("data", msg);
	}
});
proxy.bind(65000);

gameServer("5.196.39.50", 27015, "s7t5dooz");
gameServer("5.196.39.51", 27025, "8c8vli37");

function gameServer(ip, port, pw) {
    var myIP = '5.196.39.48';
    try {
        var game = new Rcon(ip, port, pw);

        game.on('auth', function() {
            game.send('logaddress_del "'+myIP+':65000"');
            game.send('logaddress_add "'+myIP+':65000"');
        });
        game.on('error', function() {
            setTimeout( function() {
                gameServer(ip, port);
            }, 1000);
        });
        game.on('end', function() {
            setTimeout( function() {
                gameServer(ip, port);
            }, 100);
        });
        game.connect();
    } catch ( err ) {
        console.log(ip+":"+port+"---> "+err);
    }
}



};
