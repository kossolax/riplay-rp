"use strict";
var sys = require('util')
var exec = require('child_process').exec;

exports = module.exports = function(server){
  var moment = require('moment');
  var ERR = require('node-restify-errors');
  var request = require('request');


  function lzw_encode(s) {
    var dict = {};
    var data = (s + "").split("");
    var out = [];
    var currChar;
    var phrase = data[0];
    var code = 256;
    for (var i=1; i<data.length; i++) {
        currChar=data[i];
        if (dict[phrase + currChar] != null) {
            phrase += currChar;
        }
        else {
            out.push(phrase.length > 1 ? dict[phrase] : phrase.charCodeAt(0));
            dict[phrase + currChar] = code;
            code++;
            phrase=currChar;
        }
    }
    out.push(phrase.length > 1 ? dict[phrase] : phrase.charCodeAt(0));
    for (var i=0; i<out.length; i++) {
        out[i] = String.fromCharCode(out[i]);
    }
    return out.join("");
  }

  function validateTokken(req, tokken, callback) {
    //var pattern = /^STEAM_[01]:[01]:[0-9]{1,18}$/g;
    var pattern = /^[0-9]{17}$/g;

    if( pattern.test(tokken) ) {
      server.conn.query(server.getAuthAdminID, [req.headers.auth], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) {
          server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
            if( err ) return res.send(new ERR.InternalServerError(err));
            if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

            var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

            server.conn.query("SELECT * FROM `rp_csgo`.`rp_tribunal` WHERE `steamid`=? AND `uniqID`=? AND `timestamp`+(30*60*60)>=UNIX_TIMESTAMP()", [tokken.replace("STEAM_0", "STEAM_1").trim(), SteamID], function(err, row) {
              if( err ) return res.send(new ERR.InternalServerError(err));

              if( row[0] == null ) {
                server.conn.query("SELECT `job_id` FROM `rp_users` WHERE `steamid`=?", [SteamID], function(err, row) {
                  if( err ) return res.send(new ERR.InternalServerError(err));
                  if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
                  if( row[0].job_id >= 101 && row[0].job_id <= 109 ) {
                    var dStart = moment().subtract(2, 'hour').toDate();
                    var dEnd = moment().add(1, 'hour').toDate();
                    var target = tokken.replace("STEAM_0", "STEAM_1").trim();

                    request("http://5.196.39.48:8080/live/connected/"+target, function (error, response, body) {
                      if( body == '"1"' )
                        callback(null, target, dStart, dEnd);
                      else
                        callback("InvalidParam" + target);
                    });

                  }
                  else {
                    callback("InvalidParam");
                  }
                });
              }
              else {
                var dStart = moment().subtract(7, 'days').toDate();
                var dEnd = moment().add(1, 'hour').toDate();
                callback(null, tokken.replace("STEAM_0", "STEAM_1").trim(), dStart, dEnd);
              }
            });
          });
        }
        else {
          var dStart = moment().subtract(7, 'days').toDate();
          var dEnd = moment().add(1, 'hour').toDate();

          callback(null, tokken.replace("STEAM_0", "STEAM_1").trim(), dStart, dEnd);
        }
      });
    }
    else if( !isNaN(parseInt(tokken)) && parseInt(tokken) > 0 ) {
      server.conn.query("SELECT * FROM `rp_report`.`site_report` WHERE `id`=?", [parseInt(tokken)], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

        var dStart = moment.unix(row[0].timestamp).subtract(1, 'hour').toDate();
        var dEnd = moment.unix(row[0].timestamp).add(1, 'hour').toDate();

        delete row[0].own_ip;
        delete row[0].own_steamid;
        delete row[0].report_date;

        callback(null, row[0].report_steamid.replace("STEAM_0", "STEAM_1").trim(), dStart, dEnd, row[0]);
      });
    }
    else {
      callback("InvalidParam");
    }
  }
  /**
   * @api {get} /tribunal/:id GetTribunal
   * @apiName GetTribunal
   * @apiGroup Tribunal
   * @apiPermission user
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {String} id
   */
  server.get('/tribunal/next', function (req, res, next) {
  	try {

      server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

        var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

        server.conn.query("SELECT `id` FROM `rp_report`.`site_report` R WHERE `jail`='-1' AND `id` NOT IN (SELECT `reportid` FROM `rp_report`.`site_report_votes` V WHERE V.`steamid`=? ) ORDER BY `timestamp` ASC LIMIT 1;", [SteamID], function(err, row) {
          if( err ) return res.send(new ERR.InternalServerError(err));
          if( row[0] == null ) return res.send(new ERR.NotFoundError("NotFound"));

          return res.send(row[0]);
        });
      });
    } catch ( err ) {
      return res.send(err);
    }
    next();
  });
  /**
   * @api {get} /tribunal/last
   * @apiName GetTribunal
   * @apiGroup Tribunal
   * @apiPermission user
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {String} id
   */
  server.get('/tribunal/last', function (req, res, next) {
    var cache = server.cache.get( req._url.pathname);
    if( cache != undefined ) { return res.send(cache); }

    	server.conn.query("SELECT `id`, U.`steamid`, U.`name`, `report_raison`, `timestamp`, `jail`, `amende`, `reason`, U2.`steamid` as juge, U2.`name` as `jugeName` FROM `rp_report`.`site_report` R INNER JOIN `rp_csgo`.`rp_users` U ON U.`steamid`=R.`report_steamid` LEFT JOIN `rp_csgo`.`rp_users` U2 ON U2.`steamid`=R.`juge` ORDER BY `timestamp` DESC LIMIT 50;", function(err, row) {
      if( err ) return res.send(new ERR.InternalServerError(err));

      server.cache.set( req._url.pathname, row);
      return res.send(row);
    });
    next();
  });

  /**
   * @api {get} /tribunal/mine
   * @apiName GetTribunal
   * @apiGroup Tribunal
   * @apiPermission user
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {String} id
   */
   server.get('/tribunal/mine', function (req, res, next) {
     try {
       server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
        console.log("header:" + req.headers.auth);

         if( err ) return res.send(new ERR.InternalServerError(err));
         if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

         var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

         server.conn.query("SELECT `id`, U.`steamid`, U.`name`, `report_raison`, `timestamp`, `jail`, `amende`, `reason`, U2.`steamid` as juge, U2.`name` as `jugeName` FROM `rp_report`.`site_report` R INNER JOIN `rp_csgo`.`rp_users` U ON U.`steamid`=R.`report_steamid` INNER JOIN `rp_csgo`.`rp_users` U2 ON U2.`steamid`=R.`juge` WHERE `own_steamid`=? OR `report_steamid`=? ORDER BY `id` DESC LIMIT 50;", [SteamID, SteamID], function(err, row) {
           if( err ) return res.send(new ERR.InternalServerError(err));

           return res.send(row);
         });
       });
     } catch ( err ) {
       return res.send(err);
     }
     next();
   });
  /**
   * @api {get} /tribunal/:id GetTribunal
   * @apiName GetTribunal
   * @apiGroup Tribunal
   * @apiPermission user
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {String} id
   */
  server.get('/tribunal/:id', function (req, res, next) {
  	try {
      validateTokken(req, req.params['id'], function(err, tSteamID, dStart, dEnd, more) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        server.conn.query("SELECT SUM(IF(vote=1,1,0)) AS condamner, SUM(IF(vote=0,1,0)) AS acquitter FROM `rp_report`.`site_report_votes` WHERE reportid=? GROUP BY `steamid`", [req.params['id']], function(err, rows) {
          return res.send({steamid: tSteamID, dStart, dEnd, data: more, condamner: rows[0] ? rows[0].condamner : 0, acquitter: rows[0] ? rows[0].acquitter : 0});
        });
      });
    } catch ( err ) {
      return res.send(err);
    }
    next();
  });

  /**
   * @api {put} /tribunal/:id/:type/:vote VoteTribunal
   * @apiName VoteTribunal
   * @apiGroup Tribunal
   * @apiPermission user
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {String} id
   * @apiParam {String} vote
   */
  server.put('/tribunal/:id/:vote', function (req, res, next) {
    try {
      validateTokken(req, req.params['id'], function(err, tSteamID, dStart, dEnd) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
          if( err ) return res.send(new ERR.InternalServerError(err));
          if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

          var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

          server.conn.query("DELETE `rp_report`.`site_report_votes` WHERE `reportid`=? AND `steamid`=?", [req.params['id'], SteamID], function(err, row) {
            server.conn.query("INSERT INTO `rp_report`.`site_report_votes`(`reportid`, `steamid`, `vote`) VALUES (?, ?, ?);", [req.params['id'], SteamID, req.params['vote']], function(err, row) {
              return res.send({redirect: "/tribunal/rules", message: "Votre vote a bien été pris en compte, merci!"});
            });
          });
        });
      });
    } catch ( err ) {
      return res.send(err);
    }
    next();
  });
/**
 * @api {get} /tribunal/:id/:type GetTribunalInformation
 * @apiName GetTribunalInformation
 * @apiGroup Tribunal
 * @apiPermission user
 * @apiHeader {String} auth Votre cookie de connexion.
 * @apiParam {String} id
 * @apiParam {String} type
 */
server.get('/tribunal/:id/:type', function (req, res, next) {
	try {
    validateTokken(req, req.params['id'], function(err, tSteamID, dStart, dEnd) {

      if( err ) return res.send(new ERR.InternalServerError(err));

      var cache = server.cache.get( req._url.pathname);
      if( cache != undefined ) return res.send(cache);

      var type = req.params['type'];
      var sqlTYPE = "";
      switch(type) {
        case "money": case "steal": case "kill": case "chat": case "item": case "jail": case "other":
          sqlTYPE = "`type`='"+type+"'"; break;
        case "connect":
          sqlTYPE = "`type` IN ('connect', 'disconnect', 'afk', 'noafk')"; break;
        case "buy":
          sqlTYPE = "`type` IN ('buy', 'loto')";  break;
        default: throw "InvalidType";
      }

      var sql = " SELECT `line` FROM `rp_bigdata` ";
      sql += "    WHERE `date`>? AND `date`<? AND "+sqlTYPE+" AND (`steamid`=? OR `target`=?) ORDER BY `date` DESC;";

      server.conn.query(sql, [dStart, dEnd, tSteamID, tSteamID], function( err, row ) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        var obj = new Array();
        for(var i=0; i<row.length; i++) {
          obj.push(row[i].line);
        }

        server.cache.set(req._url.pathname, obj);
        return res.send(obj);
      });
    });
  } catch ( err ) {
    return res.send(err);
  }
  next();
});

};
