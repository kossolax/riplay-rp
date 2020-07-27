"use strict";
var sys = require('util')
var exec = require('child_process').exec;
var request = require('request');

exports = module.exports = function(server) {
  var moment = require('moment');
  var ERR = require('node-restify-errors');

  /**
  * @api {post} /report/police SendReportPolice
  * @apiName SendReportPolice
  * @apiGroup Report
  * @apiPermission user
  * @apiHeader {String} auth Votre cookie de connexion.
  * @apiParam {String} steamid Un identifiant unique Steam.
  * @apiParam {Integer} timestamp La date, selon le joueur
  * @apiParam {String} reason La raison
  * @apiParam {String} moreinfo Info supplémentaire
  */
  server.post('/report/police', function (req, res, next) {
    try {
      if( !req.params['steamid'] || !req.params['timestamp'] || !req.params['reason'] || !req.params['moreinfo'] ) return res.send(new ERR.BadRequestError("InvalidParam"));
      var d = new Date(req.params['timestamp']);
      if(!(d instanceof Date && isFinite(d))) return res.send(new ERR.BadRequestError("InvalidDate"));

      server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
	if( row[0].steamid == 'notset' ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

	server.conn.query("SELECT * FROM `rp_csgo`.`srv_bans` WHERE `SteamID`=? AND (`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0' AND `game`<>'whitelist';", [row[0].steamid], function(err, row2) {
	  if( row2[0] != null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
          var steamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

          server.conn.query("INSERT INTO `rp_csgo`.`rp_messages` (`id`, `title`, `text`, `timestamp`, `steamid`, `reportSteamID`) VALUES (NULL, ?, ?, ?, ?, ?);", [req.params['reason'], req.params['moreinfo'],  parseInt(d.getTime()/1000), steamID, req.params['steamid']], function(err, row) {
            if( err ) return res.send(new ERR.InternalServerError(err));

            var ID = row.insertId;


            server.conn.query("INSERT INTO `rp_csgo`.`rp_messages_seen` (`messageid`, `steamid`) (SELECT ?, `steamid` FROM `rp_users` WHERE `job_id` IN (1,2,101,102) OR `refere` = 1 OR `steamid`=? OR `steamid`=?);", [ID, req.params['steamid'], steamID], function( err, row ) {
              if( err ) return res.send(new ERR.InternalServerError(err));

              return res.send({'id': ID});
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
  * @api {post} /report/police SendReportTribunal
  * @apiName SendReportTribunal
  * @apiGroup Report
  * @apiPermission user
  * @apiHeader {String} auth Votre cookie de connexion.
  * @apiParam {String} steamid Un identifiant unique Steam.
  * @apiParam {Integer} timestamp La date, selon le joueur
  * @apiParam {String} reason La raison
  * @apiParam {String} moreinfo Info supplémentaire
  */
  server.post('/report/tribunal', function (req, res, next) {
    try {
      if( !req.params['steamid'] || !req.params['timestamp'] || !req.params['reason'] || !req.params['moreinfo'] ) return res.send(new ERR.BadRequestError("InvalidParam"));
      var d = new Date(req.params['timestamp']);
      if(!(d instanceof Date && isFinite(d))) return res.send(new ERR.BadRequestError("InvalidDate"));

      server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
        console.log("HEADER /report/tribunal/ " + req.headers.auth);
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

        var steamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

        server.conn.query("SELECT * FROM `rp_report`.`site_report` WHERE `report_steamid`=? AND `report_raison`=? AND `timestamp`>? AND `timestamp`<? LIMIT 1",
        [req.params['steamid'], req.params['reason'], parseInt(d.getTime()/1000)-1800, parseInt(d.getTime()/1000)+1800], function(err, rows) {
          if( rows.length != 0 ) return res.send({'id': rows[0].id});
          server.conn.query("INSERT INTO `rp_report`.`site_report` (`id`, `own_steamid`, `own_ip`, `report_steamid`, `report_raison`, `report_date`, `report_moreinfo`, `timestamp`)  VALUES (NULL, ?, ?, ?, ?, ?, ?, ?);",
          [steamID, req.connection.remoteAddress, req.params['steamid'], req.params['reason'], moment(d).format('\\L\\e DD/MM à HH:mm'), req.params['moreinfo'],  parseInt(d.getTime()/1000)], function(err, row) {
            if( err ) return res.send(new ERR.InternalServerError(err));
	    return res.send({'id': row.insertId});
            //request("http://178.32.42.113:27015/njs/report/"+req.params['steamid']+"/"+req.params['reason'].replace('/', ', ')+"", function (error, response, body) {
            //  return res.send({'id': row.insertId});
            //});
          });
        });
      });
    } catch ( err ) {
      return res.send(err);
    }
    next();
  });
  /**
  * @api {get} /report GetReports
  * @apiName GetReports
  * @apiGroup Report
  * @apiPermission user
  * @apiHeader {String} auth Votre cookie de connexion.
  */
  server.get('/report', function (req, res, next) {
    try {
      if( req.params['id'] == 0 ) return res.send(new ERR.BadRequestError("InvalidParam"));
      server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) {
          return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
        }

        server.conn.query("SELECT * FROM `rp_csgo`.`srv_bans` WHERE `SteamID`=? AND (`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0' AND `game`<>'whitelist';", [row[0].steamid], function(err, row2) {
          if( row2[0] != null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

          var steamID = row[0].steamid.replace("STEAM_0", "STEAM_1");
  
          server.conn.query("SELECT M.`id`, M.`title`, `seen`, `timestamp`, U.`name` as 'name', U2.`name` as 'plaignant' FROM `rp_csgo`.`rp_messages` M INNER JOIN `rp_csgo`.`rp_messages_seen` MS ON MS.`messageid`=M.`id` INNER JOIN `rp_csgo`.`rp_users` U ON M.`reportSteamID`=U.`steamid` INNER JOIN `rp_csgo`.`rp_users` U2 ON M.`SteamID`=U2.`steamid` WHERE MS.`steamid`=? AND `linked_to` IS NULL AND ((M.`lock`=1 AND MS.`seen`=0) OR M.`lock`=0) ORDER BY M.`timestamp` DESC", [steamID], function( err, row ) {
            if( err ) return res.send(new ERR.InternalServerError(err));
            if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
            res.send( row );
          });
        });
      });
    } catch ( err ) {
      return res.send(""+err);
    }
    next();
  });
  /**
  * @api {put} /report/:id SetReportLock
  * @apiName SetReportLock
  * @apiGroup Report
  * @apiPermission user
  * @apiHeader {String} auth Votre cookie de connexion.
  * @apiParam {Integer} id Un identifiant unique du topic
  * @apiParam {Integer} lock Faut-il verouiller le message, oui ou non?
  */
  server.put('/report/:id', function (req, res, next) {
    try {
      if( req.params['id'] == 0 && req.params['lock'] === undefined ) return res.send(new ERR.BadRequestError("InvalidParam"));
      server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

        var steamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

        server.conn.query("SELECT `steamid` FROM `rp_csgo`.`rp_messages_seen` WHERE `messageid`=? AND `steamid`=?", [req.params['id'], steamID], function( err, row ) {
          if( err ) return res.send(new ERR.InternalServerError(err));
          if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

          server.conn.query("UPDATE `rp_csgo`.`rp_messages_seen` SET `seen`=1 WHERE `messageid`=? AND `steamid`<>(SELECT `steamid` FROM `rp_csgo`.`rp_messages` WHERE `id`=?) AND  `steamid`<>(SELECT `reportSteamID` FROM `rp_csgo`.`rp_messages` WHERE `id`=?)", [req.params['id'], req.params['id'], req.params['id']], function( err, row ) {

            server.conn.query("SELECT DISTINCT `steamid` FROM `rp_csgo`.`rp_users` WHERE `job_id` IN (1,2,101,102) AND `steamid`=?;", [steamID], function( err, row ) {
              if( err ) return res.send(new ERR.InternalServerError(err));
              if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

              server.conn.query("UPDATE `rp_csgo`.`rp_messages` SET `lock`=? WHERE `id`=?", [req.params['lock'], req.params['id']], function( err, row ) {
                if( err ) return res.send(new ERR.InternalServerError(err));
                res.send("OK");
              });
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
  * @api {post} /report/read
  * @apiName PutMessagesRead
  * @apiGroup Report
  * @apiPermission user
  * @apiHeader {String} auth Votre cookie de connexion.
  */
  server.post('/report/read', function (req, res, next) {
    try {
      server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) {
          return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
        }

        var steamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

        server.conn.query("UPDATE `rp_csgo`.`rp_messages_seen` SET `seen`=1 WHERE `steamid`=?", [steamID], function( err, row ) {
          if( err ) return res.send(new ERR.InternalServerError(err));
          res.send("ok");
        });
      });
    } catch ( err ) {
      return res.send(err);
    }
    next();
});
  /**
  * @api {put} /report/:id GetReportMessage
  * @apiName GetReportMessage
  * @apiGroup Report
  * @apiPermission user
  * @apiHeader {String} auth Votre cookie de connexion.
  * @apiParam {Integer} id Un identifiant unique du topic
  */
  server.get('/report/:id', function (req, res, next) {
    try {
      if( req.params['id'] == 0 ) return res.send(new ERR.BadRequestError("InvalidParam"));
      server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

        var steamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

        server.conn.query("SELECT `job_id` FROM `rp_csgo`.`rp_messages_seen` MS INNER JOIN `rp_csgo`.`rp_users` U ON U.`steamid`=MS.`steamid` WHERE `messageid`=? AND MS.`steamid`=?", [req.params['id'], steamID], function( err, row ) {
          if( err ) return res.send(new ERR.InternalServerError(err));
          if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

          var job = row[0].job_id;

          server.conn.query("UPDATE `rp_csgo`.`rp_messages_seen` SET `seen`=1 WHERE `messageid`=? AND `steamid`=?", [req.params['id'], steamID], function( err, row ) {
            if( err ) return res.send(new ERR.InternalServerError(err));
          });

          server.conn.query("SELECT id, `title`, `text`, M.`steamid`, U.`name`, `reportSteamID`, U2.`name` as `reportName`, `timestamp`, `lock` FROM `rp_csgo`.`rp_messages` M INNER JOIN `rp_csgo`.`rp_users` U ON U.`steamid`=M.`steamid` INNER JOIN `rp_csgo`.`rp_users` U2 ON U2.`steamid`=M.`reportSteamID` WHERE `id`=?", [req.params['id']], function( err, row ) {
            if( err ) return res.send(new ERR.InternalServerError(err));
            if( job == 1 || job == 2 || job == 101 || job == 102 )
            row[0].admin = 1;
            res.send(row);
          });
        });
      });
    } catch ( err ) {
      return res.send(err);
    }
    next();
  });
  /**
  * @api {get} /report/:id/log GetReportLog
  * @apiName GetReportLog
  * @apiGroup Report
  * @apiPermission user
  * @apiHeader {String} auth Votre cookie de connexion.
  * @apiParam {Integer} id Un identifiant unique du topic
  */
  server.get('/report/:id/log', function (req, res, next) {
    try {
      if( req.params['id'] == 0 ) return res.send(new ERR.BadRequestError("InvalidParam"));
      server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

        var steamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

        server.conn.query("SELECT `steamid` FROM `rp_csgo`.`rp_messages_seen` WHERE `messageid`=? AND `steamid`=?", [req.params['id'], steamID], function( err, row ) {
          if( err ) return res.send(new ERR.InternalServerError(err));
          if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

          server.conn.query("SELECT `steamid`, `reportSteamID`, `timestamp` FROM `rp_csgo`.`rp_messages` WHERE `id`=?", [req.params['id']], function( err, row ) {
            if( err ) return res.send(new ERR.InternalServerError(err));

            var dump = new Array();
            dump[0] = new Array();
            dump[1] = new Array();

            var now = new Date(row[0].timestamp*1000);
            var y = now.getFullYear();
            var m = parseInt(now.getMonth()) + 1; if( m < 10 ) m = '0'+m;
            var d = parseInt(now.getDate()); if( d < 10 ) d = '0'+d;

            var cmd = "grep -h \"L "+m+"/"+d+"/"+y+" - \" /home/srcds/srv_csgo_rp/csgo/logs/* | egrep \""+row[0].steamid+"|"+row[0].reportSteamID+"\" | grep -v Loading | grep -v \"ADMIN-LOG\" | sort -r";
            var child = exec(cmd, {maxBuffer: 1024 * 1024}, function (err, stdout, stderr) {
              if (err !== null) return res.send(new ERR.InternalServerError(err));

              stdout = stdout.split("\n");
              for( var i= 0; i<stdout.length; i++) {
                if( stdout[i].indexOf(row[0].steamid) > -1 )
                dump[0].push(stdout[i]);
                if( stdout[i].indexOf(row[0].reportSteamID) > -1 )
                dump[1].push(stdout[i]);
              }
            });
            child.on('close', function(code) {
              res.send(dump);
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
  * @api {get} /report/:id/response GetReportResponse
  * @apiName GetReportResponse
  * @apiGroup Report
  * @apiPermission user
  * @apiHeader {String} auth Votre cookie de connexion.
  * @apiParam {Integer} id Un identifiant unique du topic
  */
  server.get('/report/:id/response', function (req, res, next) {
    try {
      if( req.params['id'] == 0 ) return res.send(new ERR.BadRequestError("InvalidParam"));

      server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

        var steamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

        server.conn.query("SELECT `steamid` FROM `rp_csgo`.`rp_messages_seen` WHERE `messageid`=? AND `steamid`=?", [req.params['id'], steamID], function( err, row ) {
          if( err ) return res.send(new ERR.InternalServerError(err));
          if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

          server.conn.query("SELECT M.`steamid`, U.`name`, `text`, `timestamp` FROM `rp_csgo`.`rp_messages` M INNER JOIN `rp_csgo`.`rp_users` U ON U.`steamid`=M.`steamid` WHERE `linked_to`=? ORDER BY `id` DESC;", [req.params['id']], function( err, row ) {
            if( err ) return res.send(new ERR.InternalServerError(err));
            res.send(row);
          });
        });
      });
    } catch ( err ) {
      return res.send(err);
    }

    next();
  });
  /**
  * @api {post} /report/reply/:id SendReportReply
  * @apiName SendReportReply
  * @apiGroup Report
  * @apiPermission user
  * @apiHeader {String} auth Votre cookie de connexion.
  * @apiParam {Integer} id Un identifiant unique du topic
  * @apiParam {String} text Le message que vous répondez
  */
  server.post('/report/:id/reply', function (req, res, next) {

    try {
      if( !req.params['id'] || !req.params['text'] )
      return res.send(new ERR.BadRequestError("InvalidParam"));
      server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

        var steamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

        server.conn.query("SELECT `steamid` FROM `rp_csgo`.`rp_messages_seen` WHERE `messageid`=?", [req.params['id']], function( err, rows ) {
          if( err ) return res.send(new ERR.InternalServerError(err));
          if( rows[0] == null ) return res.send(new ERR.NotFoundError("NotFound"));

          var found = false;
          for (var i = 0; i < rows.length; i++) if( rows[i].steamid == steamID ) found = true;

          if( !found ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

          server.conn.query("UPDATE `rp_csgo`.`rp_messages_seen` SET `seen`=0 WHERE `messageid`=? AND `steamid`<>?", [req.params['id'], steamID], function( err, row ) {
            if( err ) return res.send(new ERR.InternalServerError(err));
          });

          server.conn.query("INSERT INTO `rp_csgo`.`rp_messages` (`id`, `text`, `timestamp`, `steamid`, `linked_to`) VALUES (NULL, ?, UNIX_TIMESTAMP(), ?, ?);", [req.params['text'], steamID, req.params['id']], function(err, row) {
            if( err ) return res.send(new ERR.InternalServerError(err));

            res.send("OK");
          });
        });
      });
    } catch ( err ) {
      return res.send(err);
    }
    next();
  });

};
