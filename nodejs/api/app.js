var restify = require('restify');
var redirect = require('restify-redirect');
var fs = require('fs');
var mysql = require('mysql2');
var NodeCache = require( "node-cache" );

var server = restify.createServer();
require('./auth.js')(server);

function Pool(num_conns) {
  this.pool = [];
  for(var i=0; i < num_conns; ++i) {
    var conn = mysql.createConnection(server.sqlConfig);
    conn.connect();
    conn.on('error', function(err) {  console.log("EER"); console.log(err); setTimeout(handleDisconnect, 5000);  });
    this.pool.push(conn);
  }
  this.last = 0;
}
Pool.prototype.query = function(a, b, c, d) {
    var cli = this.pool[this.last];
    this.last++;
    if (this.last == this.pool.length)
       this.last = 0;
    return cli.query(a, b, c, d);
}

server.conn = new Pool(8);
server.cache = new NodeCache({ stdTTL: 30, checkperiod: 30 });
server.restify = restify; 
server.restify.CORS.ALLOW_HEADERS.push('origin');
server.restify.CORS.ALLOW_HEADERS.push('auth');
server.restify.CORS.ALLOW_HEADERS.push('Accept-Encoding');
server.restify.CORS.ALLOW_HEADERS.push('Accept-Language');
server.restify.CORS.ALLOW_HEADERS.push('Access-Control-Allow-Origin', '*');

function handleDisconnect() {
    console.log("fired");
    for(var i=0; i < server.conn.pool.length; i++) {
      server.conn.pool[i].end();
    }
    server.conn = new Pool(8);
}

process.on('uncaughtException', function(err, p) {
	console.log('Process Caught exception: ' + err + ' --> ' + p);
});
server.on('uncaughtException', function (request, response, route, error) {
	console.log('Server Caught exception in : '+request.path());
	console.log(error);
});

server.use(restify.acceptParser(server.acceptable));
server.use(restify.queryParser());
server.use(restify.bodyParser());
server.use(redirect());
server.use(restify.CORS({origins: ['*'], credentials: true, headers: ['auth']}));

require('./includes/serverws.js')(server);
require('./includes/user.js')(server);
require('./includes/report.js')(server);
require('./includes/items.js')(server);
require('./includes/zones.js')(server);
require('./includes/proxy.js')(server);
//require('./includes/panel.js')(server);
require('./includes/job.js')(server);
require('./includes/group.js')(server);
require('./includes/live.js')(server);
//require('./includes/forum.js')(server);
require('./includes/rank.js')(server);
require('./includes/connection.js')(server);
require('./includes/tribunal.js')(server);
require('./includes/hdv.js')(server);
//require('./includes/steam.js')(server);
require('./includes/parrain.js')(server);
//require('./includes/devzone.js')(server);
require('./includes/search.js')(server);
require('./includes/redirect.js')(server);
require('./includes/success.js')(server);

server.pre(function (request, response, next) {
	next();
});

server.get('/', function (req, res, next) {
  return res.send("hello");
});

server.listen(8080, 'cpu-linux.riplay.fr', function () {
	console.log('%s listening at %s', server.name, server.url);
});
