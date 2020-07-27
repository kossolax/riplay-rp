"use strict";
exports = module.exports = function(server) {

var Rcon = require('rcon');
var proxy = require('dgram').createSocket('udp4');
var fs = require('fs');
var socket = require("socket.io");
var https = require('https');

var io = socket.listen( https.createServer({  key: fs.readFileSync('/etc/letsencrypt/live/ts-x.eu/privkey.pem'), cert: fs.readFileSync('/etc/letsencrypt/live/ts-x.eu/fullchain.pem')}).listen(4433) );

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
	if( msg.indexOf("[TSX-RP] Loading userdata") == -1 ) {
		io.sockets.to("private_"+chan).emit("data", msg);
	}
});
proxy.bind(65000);


server.conn.query("SELECT `ip`, `port` FROM `ts-x`.`adm_serv`;", function(err, rows) {
    for(var i=0; i<rows.length; i++) {
        gameServer(rows[i].ip, rows[i].port);
    }
});

function gameServer(ip, port) {
    var myIP = '178.32.42.113';
    try {
        var game = new Rcon(ip, port, '6Chx37T');

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
