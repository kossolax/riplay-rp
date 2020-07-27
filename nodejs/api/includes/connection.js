"use strict";
exports = module.exports = function(server){
  var ERR = require('node-restify-errors');
  var moment = require('moment');
  
/**
 * @api {get} /connect/auth GetAuth
 * @apiName GetAuth
 * @apiGroup Connection
 * @apiHeader {String} auth Votre cookie de connexion.
 */
/*

*/
server.get('/connect/auth', function (req, res, next) {
  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var uid = row[0].user_id;
    return res.send(req.headers.auth);
  });
  next();
});

/**
 * @api {get} /connect/check GetCheckConnect
 * @apiName GetCheckConnect
 * @apiGroup Connection
 * @apiHeader {String} auth Votre cookie de connexion.
 */
/*

*/
server.get('/connect/check', function (req, res, next) {
  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var uid = row[0].user_id;
    return res.send("ok");
  });
  next();
});

server.get('/connect/hello/:target', function (req, res, next) {
  console.log(req.params);

  if(req.params['target'] == 0) {
    return res.send("okay, mais il me faudras un steamid :)");
  } else if( req.params['target'] == 'lambda') {
    var target = server.getAuthSteamID;
  } else if( req.params['target'] == 'root') {
    var target = server.getAuthAdminID;
  } else if( req.params['target'] == 'admin') {
    var target = server.getAuthSMAdmin;
  } else {
    return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
  }

  server.conn.query(target, [req.headers.auth], function(err, row) {
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized :)"));
    var uid = row[0].user_id;
    return res.send("Hello");
  });
  next();
});

};