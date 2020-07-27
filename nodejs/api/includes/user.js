"use strict";
exports = module.exports = function(server){
  var ERR = require('node-restify-errors');
  var moment = require('moment');
  var request = require('request');
  var statData = require('./data/assoc.json');
  var successData = require('./data/success.json');
  var gd = require('node-gd');
  var fs = require('fs');
  var sendmail = require('sendmail')();
  var TeamSpeak = require('node-teamspeak-api');
  var steamidconvert = require('steamidconvert')()

  function getVitalityLevel(points) {
    var l = Math.floor(Math.log2(points) / 2.0 - 3.0);
    if( l < 0 )
      l = 0;
    return l;
  }
  function getRank(pos) {
    if( pos == 1 ) return "Président";
    else if( pos >= 2 && pos < 4 ) return "Vice-Président";
    else if( pos >= 4 && pos < 8 ) return "Ministre";
    else if( pos >= 8 && pos < 14 ) return "Haut Conseiller";
    else if( pos >= 14 && pos < 22 ) return "Assistant-Haut Conseiller";
    else if( pos >= 22 && pos < 32 ) return "Conseiller";
    else if( pos >= 32 && pos < 46 ) return "Maire";
    else if( pos >= 46 && pos < 62 ) return "Porte-Parole";
    else if( pos >= 62 && pos < 80 ) return "Citoyen dévoué";
    else if( pos >= 80 && pos < 100 ) return "Citoyen";
    else if( pos < 0 ) return "Rôdeur";
    else return "Visiteur";
  }
  function pretty_date(seconds) {
    var year = Math.floor(seconds / ( 12*31*24*60*60));
    var month = Math.floor(seconds / (31*24*60*60) % 12);
    var day = Math.floor(seconds / (24*60*60) % 31);
    var hs = Math.floor(seconds / (60*60) % 24);
    var ms = Math.floor(seconds / 60 % 60);
    var sr = Math.floor(seconds / 1 % 60);

    var time = '';
    if (year != 0) { time += year + 'ans '; }
    if (month != 0) { time += month + 'mois '; }
    if (day != 0) { time += day + 'j '; }
    if (hs!= 0) { time += hs + 'h ';}
    if (ms!= 0) { time += ms + 'm ';}

    return time;
  }
  // bla, bla, bla... à déplacer
  function steamIDToProfile(steamID) {
    var parts = steamID.split(":");
    var iServer = Number(parts[1]);
    var iAuthID = Number(parts[2]);
    var converted = "76561197960265728"
    var lastIndex = converted.length - 1

    var toAdd = iAuthID * 2 + iServer;
    var toAddString = new String(toAdd)
    var addLastIndex = toAddString.length - 1;

    for(var i=0;i<=addLastIndex;i++) {
        var num = Number(toAddString.charAt(addLastIndex - i));
        var j=lastIndex - i;

        do {
            var num2 = Number(converted.charAt(j));
            var sum = num + num2;

            converted = converted.substr(0,j) + (sum % 10).toString() + converted.substr(j+1);

            num = Math.floor(sum / 10);
            j--;
        } while(num);
    }
    return converted;
  }

  /**
   * @api {get} /user/:SteamID GetUserBySteamID
   * @apiName GetUserBySteamID
   * @apiGroup User
   * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
   */
  server.get('/user/:id', function (req, res, next) {
    if( req.params['id'] == 0 )
      return res.send(new ERR.BadRequestError("InvalidParam"));

    var cache = server.cache.get( req._url.pathname);
    if( cache != undefined ) { return res.send(cache); };

    var sql = "SELECT U.`name`, `money` as `cash_money`, `bank` as `cash_bank`, `money`+`bank` as `cash`, U.`job_id`, `job_name`, U.`group_id`, G.`name` as `group_name`, `time_played` as `timeplayed`, ";
    sql += "`permi_lege`, `permi_lourd`, `permi_vente`, `train` as `train_knife`, `train_weapon`, `train_esquive`, ";
    sql += "`pay_to_bank`, `have_card`, `have_account`, `kill`, `death`, `refere`, `timePlayedJob`, U.`skin`, UNIX_TIMESTAMP(`last_connected`) as `last_connected`, `vitality`, `level` as `rang`, `prestige`, F.`member_id` as `forum_id`, "
    sql += "(U.job_id - (U.job_id%10))+1 as job_boss_id, `no_pyj`";
    sql += " FROM `rp_csgo`.`rp_users` U INNER JOIN `rp_csgo`.`rp_jobs` J ON J.`job_id`=U.`job_id` INNER JOIN `rp_csgo`.`rp_groups` G ON G.`id`=U.`group_id` LEFT JOIN `forum`.`ipb_core_members` F ON REPLACE(F.`steamid`, 'STEAM_0', 'STEAM_1')=U.`steamid` WHERE U.`steamid`=? ORDER BY F.`last_visit` DESC LIMIT 1;";

    server.conn.query(sql, [req.params['id']], function(err, rows) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

      rows[0].skin = (require('path').basename(rows[0].skin)).replace(/[^A-Za-z]/g, '').replace(/variant.mdl/g, '').replace(/varmdl/g, '').replace("mdl", "");
      rows[0].skin = (rows[0].skin==''? 'null' : rows[0].skin);
      rows[0].last_connected = new Date(parseInt(rows[0].last_connected)*1000);
      rows[0].steam64 = req.params['id'];
      rows[0].vitality = getVitalityLevel(rows[0].vitality);
      
      server.cache.set( req._url.pathname, rows[0]);
      return res.send( rows[0] );
    });

  	next();
  });

  /**
   * @api {get} /user/pilori/last/:page GetUserBan
   * @apiName GetUserBan
   * @apiGroup User
   */
  server.get('/user/pilori/last/:page', function (req, res, next) {

    var cache = server.cache.get( req._url.pathname);
    if( cache != undefined ) { return res.send(cache); };

    var sql = "SELECT id, REPLACE(COALESCE(N.`SteamID`, tmp.`SteamID`), 'STEAM_0', 'STEAM_1') as `SteamID`, COALESCE(`uname2`, N.`SteamID`, tmp.`SteamID`) as `nick`, `BanReason` as `reason`, `Length`, `game`, `banned`, `StartTime`, `is_unban` as `unban` FROM (";
    sql += " SELECT *, '1' as banned FROM `rp_csgo`.`srv_bans` WHERE `is_hidden`='0' AND ((`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0') ";
    sql += "   UNION ";
    sql += "   SELECT *, '0' as banned FROM `rp_csgo`.`srv_bans` WHERE `is_hidden`='0' AND NOT ((`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0') ";
    sql += " ) AS tmp LEFT JOIN `rp_csgo`.`srv_nicks` N ON REPLACE(tmp.`SteamID`, 'STEAM_0', 'STEAM_1')=N.`SteamID` ORDER BY id DESC LIMIT ?,100;";

    server.conn.query(sql, [req.params['page']*100], function(err, rows) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

      server.cache.set( req._url.pathname, rows);
      return res.send( rows );
    });
    next();
  });

  /**
   * @api {put} /user/pilori/:target/:time/:game/:reason PutUserBan
   * @apiName GetUserBan
   * @apiGroup User
   */
  server.put('/user/pilori/:target/:time/:game/:reason', function (req, res, next) {

    server.conn.query(server.getAuthSMAdmin, [req.headers.auth], function(err, row) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      var SteamID = row[0].steamid.replace("STEAM_1", "STEAM_0");
      var target = req.params['target'].replace("STEAM_1", "STEAM_0");

      var sql = "INSERT INTO `rp_csgo`.`srv_bans` (`id`, `SteamID`, `StartTime`, `EndTime`, `Length`, `adminSteamID`, `BanReason`, `game`) VALUES (NULL, ?, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()+?, ?, ?, ?, ?)";

      server.conn.query(sql, [target, req.params['time']*60, req.params['time']*60, SteamID, req.params['reason'], req.params['game']], function(err, rows) {
        if( err ) return res.send(new ERR.InternalServerError(err));

        return res.send( "OK" );
      });

      if( req.params['game'] == "forum" || req.params['game'] == "ALL" ) {
	server.conn.query("DELETE S FROM `forum`.`ipb_core_sessions` AS S INNER JOIN `forum`.`ipb_core_members` U ON S.`member_id`=U.`member_id` INNER JOIN `rp_csgo`.`srv_bans` B ON U.`steamid`=B.`steamid` WHERE (`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0' AND (`game`='forum' OR `game`='ALL')", function(err, row) { console.log(err); });
      }
      if( req.params['game'] == "teamspeak" || req.params['game'] == "ALL" ) {
        var tsClient = new TeamSpeak('176.31.38.179', 10011);
    
        tsClient.api.login({ client_login_name: "tsxbot", client_login_password: server.TSTokken}, function(err, resp, req) {
          tsClient.api.use({ sid: 1}, function(err, resp, req) {
            tsClient.send("clientupdate", {client_nickname: "[BOT2] ts-x.eu"});
            tsClient.send('clientlist', function(err, resp, req) {
              var clients = new Array();
              resp.data.forEach(function(element) {
                clients[element.client_database_id] = element.clid;
              });
              server.conn.query("SELECT `client_id` FROM `TeamSpeak`.`clients` WHERE `steamid`=?;", [target], function(err, rows) {
                for(var i=0; i<rows.length; i++) {
                  tsClient.send("servergroupdelclient", {sgid: 7, cldbid: rows[i].client_id});
                  if( clients[rows[i].client_id] > 0 )
                    tsClient.send("clientkick", {reasonid: 5, clid: clients[rows[i].client_id], reasonmsg: "banned"});
                }

                setTimeout(function() { tsClient.disconnect(); }, 3000);
              });
            });
          });
        });
      }
      next();
    });
    next();
  });
  /**
   * @api {get} /user/pilori/:SteamID GetUserBanBySteamID
   * @apiName GetUserBanBySteamID
   * @apiGroup User
   * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
   */
  server.get('/user/pilori/:id', function (req, res, next) {
    if( req.params['id'] == 0 )
      return res.send(new ERR.BadRequestError("InvalidParam"));

    var cache = server.cache.get( req._url.pathname);
    if( cache != undefined ) { return res.send(cache); };

    var sql = "SELECT `BanReason` as `reason`, `Length`, `game`, `banned`, `StartTime`, `is_unban` as `unban` FROM (";
    sql += " SELECT *, '1' as banned FROM `rp_csgo`.`srv_bans` WHERE REPLACE(`steamid`, 'STEAM_0', 'STEAM_1')=? AND `is_hidden`='0' AND ((`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0') ";
    sql += "   UNION ";
    sql += "   SELECT *, '0' as banned FROM `rp_csgo`.`srv_bans` WHERE REPLACE(`steamid`, 'STEAM_0', 'STEAM_1')=? AND `is_hidden`='0' AND NOT ((`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0') ";
    sql += " ) AS tmp ORDER BY banned DESC, id DESC; ";

    server.conn.query(sql, [req.params['id'],req.params['id']], function(err, rows) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

      server.cache.set( req._url.pathname, rows);
      return res.send( rows );
    });
    next();
  });
  /**
   * @api {get} /user/job/:SteamID/:job GetUserJobPlaytime
   * @apiName GetUserJobPlaytime
   * @apiGroup User
   * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
   * @apiParam {Integer} job Un identifiant unique du job
   */
  server.get('/user/job/:id/:job', function (req, res, next) {
    if( req.params['id'] == 0 )
      return res.send(new ERR.BadRequestError("InvalidParam"));

    var cache = server.cache.get( req._url.pathname);
    if( cache != undefined ) { return res.send(cache); };

    server.conn.query("SELECT `jobplaytime` FROM rp_csgo.`rp_users` WHERE `steamid`=?", [req.params['id']], function(err, rows) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

      var result = 0;
      var data = rows[0].jobplaytime.split(";");
      for(var i=0; i<data.length; i++) {
        var row = data[i].split(",");
        if( row[0] == req.params['job'] )
          result = row[1];
      }
      server.cache.set( req._url.pathname, ""+result);
      return res.send( ""+result );
    });
    next();
  });
  /**
   * @api {get} /user/job/:SteamID GetUserJobPlaytime
   * @apiName GetUserJobPlaytime
   * @apiGroup User
   * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
   */
  server.get('/user/job/:id', function (req, res, next) {

    var cache = server.cache.get( req._url.pathname);
    if( cache != undefined ) { return res.send(cache); };

    server.conn.query("SELECT `job_id`, `job_name`, `is_boss` FROM `rp_csgo`.`rp_jobs`;", [req.params['id']], function(err, rows) {
      if( err ) return res.send(new ERR.InternalServerError(err));

      var jobs = new Array();
      for(var i=0; i<rows.length; i++) {
        jobs[ rows[i].job_id ] = rows[i].job_name;

        if( rows[i].is_boss  ) {
          jobs[ rows[i].job_id - 1 ] = (rows[i].job_name).substring( (rows[i].job_name).indexOf(" - ") + 3);
        }

      }

      server.conn.query("SELECT `jobplaytime` FROM `rp_csgo`.`rp_users` WHERE `steamid`=?", [req.params['id']], function(err, rows) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

        var result = {};

        var data = rows[0].jobplaytime.split(";");
        for(var i=0; i<data.length - 1; i++) {
          var row = data[i].split(",");
          result[ row[0] ] = {name: jobs[row[0]], time: row[1]};
        }

        server.cache.set( req._url.pathname, result);
        return res.send( result );
      });

      next();
    });
    next();
  });

  /**
   * @api {get} /user/pilori/:SteamID/next GetUserNextBanBySteamID
   * @apiName GetUserNextBanBySteamID
   * @apiGroup User
   * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
   */
  server.get('/user/pilori/:id/next', function (req, res, next) {
    if( req.params['id'] == 0 )
      return res.send(new ERR.BadRequestError("InvalidParam"));

    var cache = server.cache.get( req._url.pathname);
    if( cache != undefined ) { return res.send(cache); };

    var obj = {irrespect: 0, spam: 0, event: 0, usebug: 0, cheat: 0, double: 0, refus: 0, freekill: 0, autres: 0};
    var filter = {
      irrespect: new RegExp(/(insulte)|(respect)|(provocation)|(lourd)|(calmer)|(gueule)|(racis)|(propos)|(menace)|(gag)|(rage)|(affaire)/),
      spam: new RegExp(/(flood)|(spam)|(hldj)|(micro)|(musique)|(music)/),
      event: new RegExp(/(event)|(braquage)|(quete)|(nuisible)|(évent)|(quête)/),
      usebug: new RegExp(/(bug)/),
      cheat: new RegExp(/(cheat)|(hack)|(triche)|(exploit)|(ddos)/),
      double: new RegExp(/(double)/),
      refus : new RegExp(/(refus)|(black)/),
      freekill : new RegExp(/(freekill)|(fk massif)/)
    };

    var obj2 = {irrespect: new Array(), spam: new Array(), event: new Array(), usebug: new Array(), cheat: new Array(), double: new Array(), refus: new Array(), freekill: new Array(), autres: new Array()};

    server.conn.query("SELECT * FROM `rp_csgo`.`srv_bans` WHERE REPLACE(`steamid`, 'STEAM_0', 'STEAM_1')=?;", [req.params['id']], function(err, rows) {
      if( err ) return res.send(new ERR.InternalServerError(err));
//      if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

      var k = 0;
      var found = false;

      for(var i=0; i<rows.length; i++) {

        found = false;

        for(var j=0; j<Object.keys(filter).length; j++) {
          if( filter[Object.keys(filter)[j]].exec(rows[i].BanReason.toLowerCase()) ) {

            obj[Object.keys(filter)[j]]++;
            obj2[Object.keys(filter)[j]].push(rows[i].BanReason);

            found = true;
          }
        }

        if( ! found ) {
          obj.autres++;
          obj2["autres"].push(rows[i].BanReason);
        }
      }

      server.cache.set( req._url.pathname, {count: obj, other: obj2});
      return res.send( {count: obj, other: obj2} );
    });
    next();
  });
  /**
   * @api {get} /user/double/steamid/:SteamID GetUserDoubleBySteamID
   * @apiName GetUserDoubleBySteamID
   * @apiGroup User
   * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
   */
  server.get('/user/double/steamid/:id', function (req, res, next) {
    if( req.params['id'] == 0 )
      return res.send(new ERR.BadRequestError("InvalidParam"));

    server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
      var sub = " AND `approuved`='1'";

      if( !err && row.length == 1 && row[0].steamid.replace("STEAM_0", "STEAM_1") == req.params['id'] ) sub = "";

      var sql = "SELECT DISTINCT `steamid` FROM `rp_csgo`.`rp_ip` WHERE `ip` IN ( SELECT DISTINCT `ip` FROM `rp_ip` WHERE `steamid` IN ( ";

      sql += " SELECT DISTINCT `steamid` FROM `rp_csgo`.`rp_ip` WHERE `ip` IN ( ";
      sql += " SELECT `ip` FROM `rp_csgo`.`rp_ip` WHERE `steamid`=? )";

      sql += " AND `steamid` NOT IN (SELECT `target` FROM `rp_csgo`.`rp_double_contest` WHERE `steamid`=? "+sub+") ";
      sql += " AND `steamid` NOT IN (SELECT `steamid` FROM `rp_csgo`.`rp_double_contest` WHERE `target`=? "+sub+") ";

      sql += " )) ";

      sql += " AND `steamid` NOT IN (SELECT `target` FROM `rp_csgo`.`rp_double_contest` WHERE `steamid`=? "+sub+") ";
      sql += " AND `steamid` NOT IN (SELECT `steamid` FROM `rp_csgo`.`rp_double_contest` WHERE `target`=? "+sub+") ";

      server.conn.query(sql, [req.params['id'],req.params['id'],req.params['id'],req.params['id'],req.params['id']], function(err, rows) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));
        var data = new Array();
        for(var i=0; i<rows.length; i++)
          data.push(rows[i].steamid);

        server.cache.set( req._url.pathname, data);
        return res.send( data );
      });

      next();
    });

    next();
  });
  /**
   * @api {get} /user/double/ip/:IP GetUserDoubleByIP
   * @apiName GetUserDoubleByIP
   * @apiGroup User
   * @apiParam {String} IP
   */
  server.get('/user/double/ip/:id', function (req, res, next) {
    if( req.params['id'] == 0 )
      return res.send(new ERR.BadRequestError("InvalidParam"));

    var cache = server.cache.get( req._url.pathname);
    if( cache != undefined ) { return res.send(cache); };

    var sql = "SELECT DISTINCT `steamid` FROM `rp_csgo`.`rp_ip` WHERE `ip` IN ( SELECT DISTINCT `ip` FROM `rp_csgo`.`rp_ip` WHERE `steamid` IN ( ";
    sql += "SELECT DISTINCT `steamid` FROM `rp_csgo`.`rp_ip` WHERE `ip` IN ( SELECT DISTINCT `ip` FROM `rp_csgo`.`rp_ip` WHERE `steamid` IN ( ";
    sql += " SELECT DISTINCT `steamid` FROM `rp_csgo`.`rp_ip` WHERE `ip`=? )))) ";

    server.conn.query(sql, [req.params['id']], function(err, rows) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));
      var data = new Array();
      for(var i=0; i<rows.length; i++)
        data.push(rows[i].steamid);

      server.cache.set( req._url.pathname, data);
      return res.send( data );
    });

    next();
  });
  /**
   * @api {put} /user/double/deny/:target/:reason UserDoubleDeny
   * @apiName UserDoubleDeny
   * @apiGroup User
   * @apiParam {String} SteamID
   * @apiParam {String} reason
   */
  server.put('/user/double/deny/:target/:reason', function (req, res, next) {
    if( req.params['id'] == 0 )
      return res.send(new ERR.BadRequestError("InvalidParam"));

    server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");
      var UserName = row[0].username_clean;

      var mail = "<input type='text' value='"+ SteamID + "'/> conteste <input type='text' value='" + req.params['target'] + "'/> <br />"+ req.params['reason'];
      server.conn.query("INSERT INTO `rp_double_contest` (`steamid`, `target`, `approuved`) VALUES (?, ?, ?);", [SteamID, req.params['target'], parseInt(req.params['reason'])], function(err, rows) {
	if( err ) return res.send(new ERR.BadRequestError("Impossible de contester ce double-compte."));

        sendmail({from: 'account@ts-x.eu', to: 'kossolax@ts-x.eu', subject: 'Double compte: '+ UserName, html: mail }, function(err, reply) {
          return res.send("Votre contestation va être annalysée sous les 24 heures.");
        });
      });

    });
    next();
  });

  /**
   * @api {get} /user/:id/signature/:type GetUserSignature
   * @apiName GetUserSignature
   * @apiGroup User
   * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
   * @apiParam {String} type Un identifiant unique sous le format STEAM_1:x:xxxxxxx
   */
  server.get('/user/:id/signature/:type', function (req, res, next) {
    var cache = server.cache.get( req._url.pathname);
    if( cache != undefined ) {
      fs.readFile(cache.content, function(err, data) {
        res.setHeader("Content-Type", "image/jpeg");
        res.writeHead(200);
        res.write(data);
        res.end();
        return next();
      });
      return next();
    }

    if( req.params['id'] == 0 )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params['type'] == 0 )
      return res.send(new ERR.BadRequestError("InvalidParam"));

    	req.params['id'] = req.params['id'].replace("STEAM_0", "STEAM_1");

      var sql = "SELECT *,  G.`name` AS  `group_name`, U.`name` AS `name`";
      sql += "  FROM  `rp_csgo`.`rp_users` U ";
      sql += "  LEFT JOIN `rp_jobs` J ON  U.`job_id`=J.`job_id` ";
      sql += "  LEFT JOIN `rp_groups` G ON U.`group_id`= G.`id` ";
      sql += "  LEFT JOIN `rp_rank` R ON U.`steamid`= R.`steamid` ";
      sql += "  LEFT JOIN `rp_idcard` I ON  U.`steamid`= I.`steamid` ";
      sql += "  WHERE  U.`steamid`=? AND R.`type`='general'";

      function write(img, x, y, text, size) {
        if( size === undefined )
          size = 15;
        var police = "/home/www/rp/fonts/tahoma.ttf";
        var black = img.colorAllocate(0,0,0);
        var white = img.colorAllocate(255,255,255);

        img.stringFT(black, police, size, 0, x+1, y+1, text);
        img.stringFT(white, police, size, 0, x, y, text);

      }
      server.conn.query(sql, [req.params['id']], function(err, rows) {
        if( err ) return res.send(new ERR.BadRequestError(err));
        if( rows.length == 0 ) return res.send(new ERR.BadRequestError("InvalidParam"));


        var cache = "/home/www/rp/cache/sign/"+req.params['type']+"-"+req.params['id']+".jpg";

        var id = rows[0].job_id;
        if( req.params['type'] == "group" )
          id = rows[0].group_id;
        id = (id - (id % 10))+1;

        var img = gd.createTrueColorSync(800, 200);
        gd.createFromJpeg("/home/www/rp/images/roleplay/"+req.params['type']+"/"+id+".jpg").then( bg => {
	        bg.copyResampled(img, 0, 0, 0, 0, 800, 200, bg.width, bg.height );
        	bg.destroy();

        	var black = img.colorAllocate(0,0,0);
        	var white = img.colorAllocate(255,255,255);
        	var alpha = img.colorAllocateAlpha(0, 0, 0, 60);

	        img.filledRectangle(50, 20, 580, 180, alpha);
	        img.rectangle(50, 20, 580, 180, black);
	        img.rectangle(0, 0, 799, 199, alpha);

	        var y = 60;
	        write(img, 80, y, "Pseudo: ");  write(img, 160, y, rows[0].name); y+= 25;
 	       write(img, 80, y, "Job: ");  write(img, 160, y, rows[0].job_name); y+= 25;
 	       if( rows[0].group_id != 0 ) {
 	         write(img, 80, y, "Groupe: ");  write(img, 160, y, rows[0].group_name); y+= 25;
 	       }
 	       if( rows[0].rank != 0 ) {
 	         write(img, 80, y, "Rang: ");  write(img, 160, y, getRank(rows[0].rank) + " (pos. "+rows[0].rank+")"); y+= 25;
 	       }
 	       write(img, 80, y, "Âge: ");  write(img, 160, y, pretty_date(rows[0].played*600)); y+= 25;

	        write(img, 608, 185, "rp.riplay.fr");
	        write(img, 635, 196, ""+new Date(), 6);

	        img.saveJpeg(cache, 100).then( _ => {
	          img.destroy();
	          fs.readFile(cache, function(err, data) {
	            res.setHeader("Content-Type", "image/jpeg");
	            res.writeHead(200);
	            res.write(data);

	            server.cache.set( req._url.pathname, {content: cache});
	            res.end();
	            return next();
		});
          });
        });
      });
  });

/**
 * @api {get} /user/search/:name GetUserByName
 * @apiName GetUserByName
 * @apiGroup User
 * @apiParam {String} name Un critère de recherche par nom
 */
server.get('/user/search/:name', function (req, res, next) {
  if( req.params['name'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) {
    cache.is_admin = false;

    server.conn.query(server.getAuthSMAdmin, [req.headers.auth], function(err, row) {
      if( row.length > 0 )
        cache.is_admin = true;
      return res.send(cache);
    });
  }
  /*var sql = "SELECT C.`steamid`, C.`name`, J.`job_name` as `job` FROM (";
  sql += " ( SELECT `steamid`, `name`, '1' as `priority` FROM `rp_csgo`.`rp_users` WHERE `name` LIKE ? ORDER BY `last_connected` DESC LIMIT 100 ) ";
  sql += " UNION ";
  sql += " ( SELECT REPLACE(`steamid`, 'STEAM_0', 'STEAM_1')  as `steamid`, CONVERT(`username` USING utf32) AS `name`, '2' as `priority` FROM `ts-x`.`phpbb3_users` WHERE `username` LIKE ? OR `username_clean` LIKE ? ORDER BY `user_lastvisit` DESC LIMIT 100) ";
  sql += " UNION ";
  sql += " ( SELECT `steamid`, `name`, '3' as `priority` FROM `rp_users` U INNER JOIN `rp_jobs` J ON U.`job_id`=J.`job_id` WHERE `job_name` LIKE ? LIMIT 100) ";
  sql += " UNION ";
  sql += " ( SELECT REPLACE(`steamid`, 'STEAM_0', 'STEAM_1'), `uname` AS `name`, '4' as `priority` FROM `ts-x`.`srv_nicks` WHERE `uname` LIKE ? OR `uname2` LIKE ? LIMIT 10) ";
  sql += " ) AS C LEFT JOIN `rp_users` U ON U.`steamid`=C.`steamid` LEFT JOIN `rp_jobs` J ON U.`job_id`=J.`job_id` WHERE C.`steamid`<>'notset' GROUP BY `steamid` ORDER BY `priority` ASC;";*/

  var sql = "SELECT C.`steamid`, C.`name`, J.`job_name` as `job` FROM (";
  sql += " ( SELECT `steamid`, `name`, '1' as `priority` FROM `rp_csgo`.`rp_users` WHERE `name` LIKE ? ORDER BY `last_connected` DESC LIMIT 100 ) ";
  sql += " UNION ";
  sql += " ( SELECT REPLACE(`steamid`, 'STEAM_0', 'STEAM_1')  as `steamid`, CONVERT(`name` USING utf32) AS `name`, '2' as `priority` FROM `forum`.`ipb_core_members` WHERE `name` LIKE ? ORDER BY `last_visit` DESC LIMIT 100) ";
  sql += " UNION ";
  sql += " ( SELECT `steamid`, `name`, '3' as `priority` FROM `rp_csgo`.`rp_users` U INNER JOIN `rp_jobs` J ON U.`job_id`=J.`job_id` WHERE `job_name` LIKE ? LIMIT 100) ";
  sql += " UNION ";
  sql += " ( SELECT REPLACE(`steamid`, 'STEAM_0', 'STEAM_1'), `uname` AS `name`, '4' as `priority` FROM `rp_csgo`.`srv_nicks` WHERE `uname` LIKE ? OR `uname2` LIKE ? LIMIT 10) ";
  sql += " ) AS C LEFT JOIN `rp_csgo`.`rp_users` U ON U.`steamid`=C.`steamid` LEFT JOIN `rp_jobs` J ON U.`job_id`=J.`job_id` WHERE C.`steamid`<>'notset' GROUP BY `steamid` ORDER BY `priority` ASC;";

  req.params['name'] = "%" + req.params['name'] + "%";
  server.conn.query(sql, [req.params['name'],req.params['name'],req.params['name'],req.params['name'],req.params['name'],req.params['name']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("NotFound"));

    for(var i=0; i<rows.length; i++)
      rows[i].steam64 = steamIDToProfile(rows[i].steamid);

    server.cache.set( req._url.pathname, rows);
    return res.send( rows );
  });

	next();
});

/**
 * @api {get} /user/:SteamID/personality GetUserPersonality
 * @apiName GetUserPersonality
 * @apiGroup User
 * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
 */
server.get('/user/:id/personality', function (req, res, next) {
  function cb(obj) {
    if( Object.keys(obj).length == 7 ) {

      var keys = Object.keys(obj).sort(function(a,b){return obj[b]-obj[a]});

      var arr = new Array();
      var max = -1;
      for(var i in obj) { if( max < obj[i] ) max = obj[i]; }
      for(var i in keys ) { arr.push( Math.round(obj[keys[i]]/max*100) );  }

      var obj2 = new Object();
      obj2.title = 'Personnalité';
      obj2.data = [{ data: arr }];
      obj2.axis = [  {categories: keys, lineWidth: 0}  ];

      server.cache.set( req._url.pathname, obj2);
      return res.send(obj2);
    }
  }
  function clamp(i, slack, min, max) {
    i = Math.round( i * 100) + slack;
    if( i < min ) i = min;
    else if( i > max ) i = max;
    return i
  }

  if( req.params['id'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) return res.send(cache);

  var obj = new Object();

  var sql = "  SELECT SUM(`amount`) `amount` ";
  sql += "    FROM `rp_csgo`.`rp_bigdata` ";
  sql += "    WHERE `type`='money' AND `steamid`=? AND `date` > CURDATE() - INTERVAL 90 DAY ";
  sql += "  UNION ";
  sql += "    SELECT SUM(`amount`) `amount` ";
  sql += "    FROM `rp_csgo`.`rp_bigdata` ";
  sql += "    WHERE `type`='money' AND `target`=? AND `date` > CURDATE() - INTERVAL 90 DAY  ";
  sql += "  UNION ";
  sql += "    SELECT (`money`+`bank`) `amount` FROM `rp_csgo`.`rp_users` WHERE `steamid`=? ";
  // Si positif, c'est qu'il est give sa thune pour frauder l'état.

  server.conn.query(sql, [req.params['id'],req.params['id'],req.params['id']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

    var inc = rows[0] ? parseFloat(rows[0].amount) : 0;
    var out = rows[1] ? parseFloat(rows[1].amount) : 0;
    var now = rows[2] ? parseFloat(rows[2].amount) : 1;

    obj.avarice = clamp((inc-out)/(inc+out+now), 33, 0, 100);
    cb(obj);
  });

  var sql = "SELECT SUM(`amount`*`prix`) `amount` FROM `rp_csgo`.`rp_sell` S ";
	sql += " INNER JOIN `rp_items` I ON I.`id`=S.`item_id` ";
	sql += " WHERE `to_steamid`=? AND `item_type`='0' AND `item_id` IN (54, 55, 56, 57, 58, 76, 115) AND `timestamp`>UNIX_TIMESTAMP()-(90*24*60*60)";
  sql += " UNION ";
  sql += " SELECT AVG(`amount`) `amount` FROM (";
  sql += " SELECT SUM(`amount`*`prix`) `amount` FROM `rp_csgo`.`rp_sell` S ";
	sql += " INNER JOIN `rp_csgo`.`rp_items` I ON I.`id`=S.`item_id` ";
	sql += " WHERE `to_steamid`<>? AND `item_type`='0' AND `item_id` IN (54, 55, 56, 57, 58, 76, 115) AND `timestamp`>UNIX_TIMESTAMP()-(90*24*60*60) GROUP BY `steamid`";
  sql += " ) zboub "
  //
  server.conn.query(sql, [req.params['id'], req.params['id']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

    var a = rows[0] ? parseFloat(rows[0].amount) : 0;
    var b = rows[1] ? parseFloat(rows[1].amount) : 1;

    obj.luxure = clamp(a/(a+b), 0, 0, 100);
    cb(obj);
  });


  var sql = "SELECT SUM(`amount`*`prix`) `amount` FROM `rp_csgo`.`rp_sell` S ";
	sql += " INNER JOIN `rp_items` I ON I.`id`=S.`item_id` ";
	sql += " WHERE `to_steamid`=? AND `item_type`='0' AND `item_id` NOT IN (54, 55, 56, 57, 58, 76, 115) AND `timestamp`>UNIX_TIMESTAMP()-(90*24*60*60)";
  sql += " UNION ";
  sql += " SELECT AVG(`amount`) `amount` FROM (";
  sql += " SELECT SUM(`amount`*`prix`) `amount` FROM `rp_csgo`.`rp_sell` S ";
	sql += " INNER JOIN `rp_csgo`.`rp_items` I ON I.`id`=S.`item_id` ";
	sql += " WHERE `to_steamid`<>? AND `item_type`='0' AND `item_id` NOT IN (54, 55, 56, 57, 58, 76, 115) AND `timestamp`>UNIX_TIMESTAMP()-(90*24*60*60) GROUP BY `steamid`";
  sql += " ) zboub "
  //
  server.conn.query(sql, [req.params['id'], req.params['id']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

    var a = rows[0] ? parseFloat(rows[0].amount) : 0;
    var b = rows[1] ? parseFloat(rows[1].amount) : 1;

    obj.gourmandise = clamp(a/(a+b), 0, 0, 100);
    cb(obj);
  });

  var sql = "  SELECT COUNT(*) `amount` ";
  sql += "    FROM `rp_csgo`.`rp_bigdata` ";
  sql += "    WHERE `type`='kill' AND `steamid`=?  AND `date` > CURDATE() - INTERVAL 30 DAY ";
  sql += "  UNION ";
  sql += "    SELECT COUNT(*) `amount` ";
  sql += "    FROM `rp_csgo`.`rp_bigdata` ";
  sql += "    WHERE `type`='kill' AND `target`=?  AND `date` > CURDATE() - INTERVAL 30 DAY ";

  server.conn.query(sql, [req.params['id'],req.params['id']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

    var a = rows[0] ? parseFloat(rows[0].amount) : 0;
    var b = rows[1] ? parseFloat(rows[1].amount) : 1;

    obj.colere = clamp(a/(a+b) * 1.2, 0, 0, 100);
    cb(obj);
  });


  var sql = "  SELECT COUNT(*) `amount` ";
  sql += " FROM `rp_csgo`.`srv_bans` ";
  sql += " WHERE REPLACE(`steamid`, 'STEAM_0', 'STEAM_1')=? AND (`StartTime`>=UNIX_TIMESTAMP()-(90*24*60*60) OR `EndTime`>=UNIX_TIMESTAMP()-(90*24*60*60)) ";
  sql += " UNION ";
  sql += " SELECT AVG(`amount`) `amount` FROM (";
  sql += "   SELECT COUNT(*) `amount` ";
  sql += "    FROM `rp_csgo`.`srv_bans` ";
  sql += "    WHERE REPLACE(`steamid`, 'STEAM_0', 'STEAM_1')<>? AND (`StartTime`>=UNIX_TIMESTAMP()-(90*24*60*60) OR `EndTime`>=UNIX_TIMESTAMP()-(90*24*60*60))  GROUP BY REPLACE(`steamid`, 'STEAM_0', 'STEAM_1') ";
  sql += " ) zboub "

  server.conn.query(sql, [req.params['id'], req.params['id'] ], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

    var a = rows[0] ? parseFloat(rows[0].amount) : 0;
    var b = rows[1] ? parseFloat(rows[1].amount) : 1;

    obj.orgueil = clamp(a/b * 0.33, 0, 0, 100);
    cb(obj);
  });

  var sql = "SELECT SUM(`amount`) `amount` ";
  sql += "  FROM `rp_csgo`.`rp_sell` ";
  sql += "  WHERE `item_type`='4' AND `item_name` LIKE 'Vol:%' AND `steamid`=? AND `timestamp`>UNIX_TIMESTAMP()-(90*24*60*60) ";
  sql += " UNION ";
  sql += " SELECT AVG(`amount`) `amount` FROM (";
  sql += "  SELECT SUM(`amount`) `amount` FROM `rp_csgo`.`rp_sell` S ";
  sql += "  WHERE `steamid`<>? AND `item_type`='4' AND `item_name` LIKE 'Vol:%' AND `timestamp`>UNIX_TIMESTAMP()-(90*24*60*60) GROUP BY `steamid`";
  sql += " ) zboub "

  server.conn.query(sql, [req.params['id'], req.params['id']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

    var a = rows[0] ? parseFloat(rows[0].amount) : 0;
    var b = rows[1] ? parseFloat(rows[1].amount) : 1;

    obj.envie = clamp(a/(a+b), 0, 0, 100);
    cb(obj);
  });

  var sql = "SELECT `fileId`, `date`, `type`, `stop` FROM ";
  sql += "  `rp_csgo`.`rp_bigdata` BD INNER JOIN `rp_csgo`.`rp_bigdata_files` BDF ON BD.`fileId`=BDF.`id` ";
  sql += " WHERE `steamid`=? AND `type` IN ('connect', 'disconnect', 'afk', 'noafk') ORDER BY `start`, BD.`id` ASC";
  server.conn.query(sql, [req.params['id']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

    var lastID = -1, connected = 0, lastDate, fileDate, connexionTime=0, afkTime=0, tmp=0;
    for(var i in rows) {

      // Détection d'un crash
      if( connected > 0 && lastID != rows[i].fileId ) {
        rows[i].date = fileDate;

        if( connected ==  2 )
          afkTime += (rows[i].date - lastDate)/1000 + (3*60);
        else
          connexionTime += (rows[i].date - lastDate)/1000;
      }

      if( rows[i].type == "connect" ) {
        lastDate = rows[i].date;
        fileDate = rows[i].stop;
        lastID = rows[i].fileId;
        connected = 1;
      }
      if( connected > 0 && rows[i].type == "afk" ) {
        connexionTime += (rows[i].date - lastDate)/1000;
        lastDate = rows[i].date;
        connected = 2;
      }
      if( connected > 0 && rows[i].type == "noafk" ) {
        afkTime += (rows[i].date - lastDate)/1000 + (3*60);
        lastDate = rows[i].date;
        connected = 1;
      }
      if( rows[i].type == "disconnect" ) {
        if( connected ==  2 )
          afkTime += (rows[i].date - lastDate)/1000 + (3*60);
        else
          connexionTime += (rows[i].date - lastDate)/1000;
        connected = 0;
      }
    }

    if( connected ==  1 ) {
      var tmp = (new Date() - lastDate)/1000
      connexionTime += tmp;
    }
    if( connected ==  2 ) {
      var tmp = (new Date() - lastDate)/1000 + (3*60);
      afkTime += tmp;
    }

    obj.paresse = clamp( afkTime / (afkTime + connexionTime), 0, 0, 100);

    cb(obj);
  });

  next();
});


/**
 * @api {get} /user/:SteamID/playtime/:type GetUserPlayTime
 * @apiName GetUserPlayTime
 * @apiGroup User
 * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
 * @apiParam {String} type month, year, 1days, 2days...7days, 31days, begin
 */
server.get('/user/:id/playtime/:type', function (req, res, next) {
  if( req.params['id'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) return res.send(cache);

  var dStart;
  var type = req.params['type'];

  switch(type) {
    case "month":  dStart = moment().startOf('month').toDate(); break;
    case "year":  dStart = moment().startOf('year').toDate(); break;
    case "31days": dStart = moment().subtract(31, 'days').toDate(); break;
    case "1days": dStart = moment().subtract(1, 'days').toDate(); break;
    case "2days": dStart = moment().subtract(2, 'days').toDate(); break;
    case "3days": dStart = moment().subtract(3, 'days').toDate(); break;
    case "4days": dStart = moment().subtract(4, 'days').toDate(); break;
    case "5days": dStart = moment().subtract(5, 'days').toDate(); break;
    case "6days": dStart = moment().subtract(6, 'days').toDate(); break;
    case "7days": dStart = moment().subtract(7, 'days').toDate(); break;

    case "begin": dStart = moment().subtract(10, 'year').toDate(); break;
    case "start": break;
    default:
      return res.send(new ERR.BadRequestError("InvalidParam"));
  }

  if( type == "start" ) {
      var sql = "SELECT `date` FROM `rp_csgo`.`rp_bigdata` WHERE `steamid`=? AND `type`='connect' ORDER BY `date` ASC LIMIT 1;";
      server.conn.query(sql, [req.params['id']], function(err, rows) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

        server.cache.set(req._url.pathname, rows[0].date);
        return res.send(rows[0].date);
      });
  }
  else {
    var sql = "SELECT `fileId`, `date`, `type`, `stop` FROM ";
    sql += "  `rp_csgo`.`rp_bigdata` BD INNER JOIN `rp_csgo`.`rp_bigdata_files` BDF ON BD.`fileId`=BDF.`id` ";
    sql += " WHERE `steamid`=? AND `type` IN ('connect', 'disconnect', 'afk', 'noafk') AND BDF.`start`>? ORDER BY `start`, BD.`id` ASC";

    var arr = [];

    function getRowById(rows, id) {
      for(var i in rows) {
        if( rows[i].fileId == id )
          return rows[i];
      }
      return undefined;
    }
    server.conn.query(sql, [req.params['id'], dStart], function(err, rows) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

      var lastID = -1, connected = 0, lastDate, fileDate, connexionTime=0, afkTime=0, tmp=0, lastRow;
      for(var i in rows) {

        // Détection d'un crash
        if( connected > 0 && lastID != rows[i].fileId ) {
          if( connected ==  2 )
            afkTime += (lastRow.stop - lastDate)/1000 + (3*60);
          else {
            connexionTime += (lastRow.stop - lastDate)/1000;
          }
        }

        if( rows[i].type == "connect" ) {
          lastDate = rows[i].date;
          fileDate = rows[i].stop;
          lastID = rows[i].fileId;
          connected = 1;
        }
        if( connected > 0 && rows[i].type == "afk" ) {
          connexionTime += (rows[i].date - lastDate)/1000 - (3*60);
          lastDate = rows[i].date;
          connected = 2;
        }
        if( connected > 0 && rows[i].type == "noafk" ) {
          afkTime += (rows[i].date - lastDate)/1000 + (3*60);
          lastDate = rows[i].date;
          connected = 1;
        }
        if( connected > 0 && rows[i].type == "disconnect" ) {
          if( connected ==  2 )
            afkTime += (rows[i].date - lastDate)/1000 + (3*60);
          else {
            connexionTime += (rows[i].date - lastDate)/1000;
          }
          connected = 0;
        }

        fileDate = rows[i].start;
        lastRow = rows[i];
      }



      if( connected ==  1 ) {
        var tmp = (new Date() - lastDate)/1000
        connexionTime += tmp;
      }
      if( connected ==  2 ) {
        var tmp = (new Date() - lastDate)/1000 + (3*60);
        afkTime += tmp;
      }

      var obj = new Object();
      obj.afk = afkTime;
      obj.play = connexionTime;

      server.cache.set(req._url.pathname, obj);
      return res.send(obj);
    });
  }
  next();
});


/**
 * @api {get} /user/:SteamID/ratio/:type GetUserRatio
 * @apiName GetUserRatio
 * @apiGroup User
 * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
 * @apiParam {String} type month, year, 31days, begin
 */
server.get('/user/:id/ratio/:type', function (req, res, next) {
  if( req.params['id'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) return res.send(cache);

  var dStart;
  var type = req.params['type'];

  switch(type) {
    case "month":  dStart = moment().startOf('month').toDate(); break;
    case "year":  dStart = moment().startOf('year').toDate(); break;
    case "31days": dStart = moment().subtract(31, 'days').toDate(); break;
    case "begin": dStart = moment().subtract(10, 'year').toDate(); break;
    default:
      return res.send(new ERR.BadRequestError("InvalidParam"));
  }

  var sql = "SELECT `steamid`, `target` FROM `rp_csgo`.`rp_bigdata` ";
  sql += " WHERE `type`='kill' AND (`steamid`=? OR `target`=?) AND `date`>?";

  server.conn.query(sql, [req.params['id'], req.params['id'], dStart], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

    var obj = new Object();
    obj.kill = obj.death = 0;

    for(var i in rows) {
      if( rows[i].steamid == req.params['id'] )
        obj.kill++;
      else
        obj.death++;
    }
    server.cache.set(req._url.pathname, obj);
    return res.send(obj);
  });

  next();
});

/**
 * @api {get} /user/:SteamID/stats GetUserStats
 * @apiName GetUserStats
 * @apiGroup User
 * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
 */
server.get('/user/:id/stats', function (req, res, next) {
  function cb(obj) {
    if( Object.keys(obj).length == 2 ) {
      server.cache.set( req._url.pathname, obj);
      return res.send(obj);
    }
  }

  if( req.params['id'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) return res.send(cache);

  var obj = new Object();
  server.conn.query("SELECT `name`, `completed`, `time` FROM `rp_csgo`.`rp_quest_book` QB INNER JOIN `rp_csgo`.`rp_quest` Q ON QB.`uniqID`=Q.`uniqID` WHERE `steamID`=? ORDER BY `time` DESC LIMIT 10;", [req.params['id']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

    for(var i=0; i<rows.length; i++)
      rows[i].time = new Date(rows[i].time*1000);

    obj.quest = rows;
    cb(obj);
  });
  server.conn.query("SELECT `stat_id`, `data` FROM `rp_csgo`.`rp_statdata` WHERE `steamID`=?;", [req.params['id']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

    var arr = new Array();
    for(var i=0; i<rows.length; i++) {
      arr.push( {name: statData[rows[i].stat_id], data: rows[i].data} )
    }
    obj.stat = arr;
    cb(obj);
  });

	next();
});

function fillArray(table, min, max, step) {
  var i = 0;
  while(min <= max) {
    if(typeof(table[i]) == 'undefined' || table[i][0] > min) {
       table.splice(i, 0, new Array(min, null));
    }
    min += step;
    i++;
  }
}

/**
 * @api {get} /user/:SteamID/incomes/:scale GetUserIncomes
 * @apiName GetUserIncomes
 * @apiGroup User
 * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
 * @apiParam {Integer} scale échelle de temps en heure. Défaut: 24
 */
server.get('/user/:id/incomes/:scale', function (req, res, next) {

  function cb(obj) {
    if( Object.keys(obj).length == 7 ) {
      var arr = [ {name: 'Les ventes', data: obj.vente, type: 'column' },
      {name: 'Les vols', data: obj.vol, type: 'column'},
      {name: 'Gains du loto', data: obj.loto, type: 'column'},
      {name: 'Les amendes', data: obj.amande, type: 'column'},
      {name: 'La paye', data: obj.pay, type: 'column'},
      {name: 'La durée de connexion', data: obj.connexion, yAxis: 1, tooltip: { valueSuffix: 'min' }}];


      var arr2 = [
        { title: { text: 'Argent gagné ($)'}, min: 0, tickAmount: 10, endOnTick:false, maxPadding: 0.0 },
        { title: { text: 'Temps de jeu (min)'}, min: 0, tickAmount: 10, endOnTick:false, maxPadding: 0.0, opposite: true}
      ];

      var obj2 = new Object();
      obj2.title = 'Argent gagné par '+obj.name;
      obj2.data = arr;
      obj2.axis = arr2;

      server.cache.set( req._url.pathname, obj2);
      return res.send(obj2);
    }
  }

  if( req.params['id'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) return res.send(cache);

  var scale = 24;
  if( req.params['scale'] != 0 )
    scale = parseInt(req.params['scale']);

  var obj = new Object();
  var day = 24*60*60*1000;
  var now = Math.floor( (new Date().getTime())/day  )*day;
  var min = now - (31*day);

  day = day/24 * scale;

  var sqlTimeColumn = "(FLOOR(`timestamp`/("+scale+"*60*60))*"+scale+"*60*60) as `date` ";
  var sql = "";
  sql += "SELECT SUM(I.`prix`*S.`amount`) AS `total`, " + sqlTimeColumn;
  sql += "	FROM `rp_csgo`.`rp_sell` S INNER JOIN `rp_csgo`.`rp_items` I ON S.`item_id`=I.`id` WHERE `steamid`=? AND `item_type`='0' GROUP BY `date` ORDER BY `date` ASC;"

  server.conn.query(sql, [req.params['id']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));

    var tmp = new Array();
    for (var i = 0, len = rows.length; i < len; i++) {
      tmp.push( Array( parseInt(rows[i].date)*1000 , parseInt(rows[i].total) ) );
    }
    fillArray(tmp, min, now, day);
    obj.vente = tmp;
    cb(obj);
  });

  sql = "SELECT SUM(`total`) as `total`, `date` FROM (";
  sql += "    SELECT SUM(I.`prix`*1) AS `total`, " + sqlTimeColumn;
  sql += "		FROM `rp_csgo`.`rp_sell` S INNER JOIN `rp_csgo`.`rp_items` I ON S.`item_id`=I.`id` WHERE `steamid`=? AND (`item_type`='2' OR (`item_type`='4' AND `item_name`='Vol: Objet')) GROUP BY `date`";
  sql += "	UNION";
  sql += "	SELECT SUM(`amount`) AS `total`, " + sqlTimeColumn;
  sql += "			FROM `rp_csgo`.`rp_sell` WHERE `steamid`=? AND `item_id`='0' AND `item_name` LIKE 'Vol: %' GROUP BY `date`";
  sql += "    ) AS VOL GROUP BY `date` ORDER BY `date` ASC;";

  server.conn.query(sql, [req.params['id'],req.params['id']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));

    var tmp = new Array();
    for (var i = 0, len = rows.length; i < len; i++) {
      tmp.push( Array( parseInt(rows[i].date)*1000 , parseInt(rows[i].total) ) );
    }
    fillArray(tmp, min, now, day);
    obj.vol = tmp;
    cb(obj);
  });

  sql = "SELECT SUM(`amount`) AS `total`, " + sqlTimeColumn;
  sql += "			FROM `rp_csgo`.`rp_sell` WHERE `steamid`=? AND `item_id`='-1' AND `item_name`='LOTO' GROUP BY `date` ORDER BY `date` ASC;";

  server.conn.query(sql, [req.params['id']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));

    var tmp = new Array();
    for (var i = 0, len = rows.length; i < len; i++) {
      tmp.push( Array( parseInt(rows[i].date)*1000 , parseInt(rows[i].total) ) );
    }
    fillArray(tmp, min, now, day);
    obj.loto = tmp;
    cb(obj);
  });

  sql = "SELECT SUM(`amount`) AS `total`, " + sqlTimeColumn;
  sql += "			FROM `rp_csgo`.`rp_sell` WHERE `steamid`=? AND (`item_type`='3' OR (`item_type`='4' AND (`item_name`='Caution' OR `item_name`='Amande'))) GROUP BY `date` ORDER BY `date` ASC;";

  server.conn.query(sql, [req.params['id']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));

    var tmp = new Array();
    for (var i = 0, len = rows.length; i < len; i++) {
      tmp.push( Array( parseInt(rows[i].date)*1000 , parseInt(rows[i].total) ) );
    }
    fillArray(tmp, min, now, day);
    obj.amende = tmp;
    cb(obj);
  });

  sql = "SELECT SUM(`amount`) AS `total`, " + sqlTimeColumn;
  sql += "			FROM `rp_csgo`.`rp_sell` WHERE `steamid`=? AND `item_type`='1' GROUP BY `date` ORDER BY `date` ASC;";
  server.conn.query(sql, [req.params['id']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));

    var tmp = new Array();
    for (var i = 0, len = rows.length; i < len; i++) {
      tmp.push( Array( parseInt(rows[i].date)*1000 , parseInt(rows[i].total) ) );
    }
    fillArray(tmp, min, now, day);
    obj.pay = tmp;
    cb(obj);
  });

  sql = "SELECT SUM(`temps`)/60 AS `total`, " + sqlTimeColumn +"	FROM `rp_csgo`.`rp_stats` WHERE `steamid`=? AND `timestamp`>(UNIX_TIMESTAMP()-(31*24*60*60)) GROUP BY `date` ORDER BY `date` ASC;"
  
  var steamid = steamidconvert.convertToText(req.params['id']);
  steamid = steamid.replace('STEAM_0', 'STEAM_1');

  server.conn.query(sql, [steamid], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));

    var tmp = new Array();
    for (var i = 0, len = rows.length; i < len; i++) {
      tmp.push( Array( parseInt(rows[i].date)*1000 , parseInt(rows[i].total) ) );
    }
    fillArray(tmp, min, now, day);
    obj.connexion = tmp;
    cb(obj);
  });

  sql = "SELECT `name`	FROM `rp_csgo`.`rp_users` WHERE `steamid`=?;"
  server.conn.query(sql, [req.params['id']], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

    obj.name = rows[0].name;
    cb(obj);
  });

  next();
});


/**
 * @api {delete} /user/:type QuitUserJobGroup
 * @apiName QuitUserJobGroup
 * @apiGroup User
 * @apiHeader {String} auth Votre cookie de connexion.
 * @apiParam {String=job,group} type
 */
server.del('/user/:type', function (req, res, next) {

  if( req.params['type'] != "group" && req.params['type'] != "job" )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");
    var UserName = row[0].name;

    var sql0;
    if( req.params['type'] == "job" )
      sql0 = "SELECT `is_boss`, J.`job_id` as `id` FROM `rp_csgo`.`rp_users` U INNER JOIN `rp_csgo`.`rp_jobs` J ON J.`job_id`=U.`job_id`  WHERE `steamid`=? LIMIT 1;";
    else if( req.params['type'] == "group" )
      sql0 = "SELECT `is_chef` as `is_boss`, U.`group_id` as `id` FROM `rp_csgo`.`rp_users` U INNER JOIN `rp_csgo`.`rp_groups` G ON G.`id`=U.`group_id`  WHERE `steamid`=? LIMIT 1;";


    var sql1 = "UPDATE `rp_csgo`.`rp_users` SET `"+req.params['type']+"_id`=0 WHERE `steamid`=? LIMIT 1;";
    var sql2 = "INSERT INTO `rp_csgo`.`rp_users2` (`id`, `steamid`, `"+req.params['type']+"_id`, `pseudo`, `steamid2`) VALUES (NULL, ?, 0, ?, ?);";

    server.conn.query(sql0, [SteamID], function(err, row) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      if( row.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));
      if( parseInt(row[0].is_boss) == 1 ) return res.send(new ERR.NotFoundError("Cannot dismiss while chief"));

      var val = parseInt(row[0].id);

      if( isNaN(val) || val == 0 )
        return res.send(new ERR.ForbiddenError("NotAuthorized: You don't have a "+ req.params['type']));

      server.conn.query(sql1, [SteamID], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        server.conn.query(sql2, [SteamID , UserName, SteamID], function(err, row) {
          if( err ) return res.send(new ERR.InternalServerError(err));

          server.cache.del("/user/"+SteamID);
          return res.send("OK");
        });
      });
    });
  });
  next();
});

/**
 * @api {put} /user/:SteamID/sendMoney/:cash sendMoneyToSteamID
 * @apiName sendMoneyToSteamID
 * @apiGroup User
 * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
 * @apiParam {Integer} cash Argent à envoyer
 */
server.put('/user/:SteamID/sendMoney/:cash', function (req, res, next) {
  if( !req.params['SteamID'] || !req.params['cash'] )
    return res.send(new ERR.BadRequestError("InvalidParam"));


  server.conn.query(server.getAuthSMAdmin, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");
    var UserName = row[0].username;
    var amount = parseInt(req.params['cash']);

    if( SteamID == req.params['SteamID'] )
      return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

    server.conn.query("SELECT `money`+`bank` as `cash` FROM `rp_csgo`.`rp_users` WHERE `steamid`=? LIMIT 1;", [SteamID], function(err, row) {
      if( err ) return res.send(new ERR.InternalServerError(err));

      if( row[0].cash < amount || amount <= 0 )
        return res.send(new ERR.NotAuthorizedError("NotEnoughtMoney"));

      request("http://178.32.42.113:27015/njs/connected/"+SteamID, function (error, response, body) {
        if( error ) return res.send(new ERR.NotFoundError("ServerNotFound"));
        if( parseInt(body) == 1 ) return res.send(new ERR.NotFoundError("YouMustBeDisconnected"));

        server.conn.query("UPDATE `rp_csgo`.`rp_users` SET `bank`=`bank`-? WHERE `steamid`=? LIMIT 1;", [amount, SteamID], function(err, row) {
          if( err ) return res.send(new ERR.InternalServerError(err));
          server.conn.query("INSERT INTO `rp_csgo`.`rp_users2` (`id`, `steamid`, `bank`, `pseudo`, `steamid2`) VALUES (NULL, ?, ?, ?, ?);", [req.params['SteamID'], amount, UserName, SteamID], function(err, row) {
            if( err ) return res.send(new ERR.InternalServerError("aaa"+err));


            server.cache.del("/user/"+SteamID);
            server.cache.del("/user/"+req.params['SteamID']);
            return res.send("OK");
          });
        });
      });
    });
  });



	next();
});

/**
 * @api {post} /user/:SteamID/giveitem giveClientItem
 * @apiName giveClientItem
 * @apiGroup User
 * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
 * @apiParam {Integer} itemid Identifiant unique de l'item à envoyer
 * @apiParam {Integer} amount la quantité à envoyer
 */
server.post('/user/:SteamID/giveitem', function (req, res, next) {

  server.conn.query(server.getAuthSMAdmin, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");
    if( SteamID != "STEAM_1:0:7490757" && SteamID != "STEAM_1:1:39278818" && SteamID != "STEAM_1:0:23617413" && SteamID != "STEAM_1:1:114134761" && SteamID != "STEAM_1:1:114134761" )
	return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

    var UserName = row[0].username;
    var amount = parseInt(req.params['amount']);
    var itemid = parseInt(req.params['itemid']);

    server.conn.query("INSERT INTO `rp_csgo`.`rp_users2` (`id`, `steamid`, `itemid`, `itemAmount`, `pseudo`, `steamid2`) VALUES (NULL, ?, ?, ?, ?, ?);", [req.params['SteamID'], itemid, amount, UserName, SteamID], function(err, row) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      return res.send("OK");
    });
  });

	next();
});
/**
 * @api {post} /user/:SteamID/givemoney giveClientMoney
 * @apiName giveClientItem
 * @apiGroup User
 * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
 * @apiParam {Integer} jobid Identifiant unique de l'item à envoyer
 * @apiParam {Integer} amount la quantité à envoyer
 */
server.post('/user/:SteamID/givemoney', function (req, res, next) {

  server.conn.query(server.getAuthSMAdmin, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");
    if( SteamID != "STEAM_1:0:7490757" && SteamID != "STEAM_1:1:39278818" && SteamID != "STEAM_1:0:23617413" && SteamID != "STEAM_1:1:114134761" && SteamID != "STEAM_1:1:114134761" )
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

    var UserName = row[0].username;
    var amount = parseInt(req.params['amount']);
    var jobid = parseInt(req.params['jobid']);

    server.conn.query("INSERT INTO `rp_csgo`.`rp_users2` (`id`, `steamid`, `job_id`, `money`, `pseudo`, `steamid2`) VALUES (NULL, ?, ?, ?, ?, ?);", [req.params['SteamID'], jobid, amount, UserName, SteamID], function(err, row) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      return res.send("OK");
    });
  });

	next();
});

/**
 * @api {post} /user/:SteamID/givexp giveClientXP
 * @apiName giveClientItem
 * @apiGroup User
 * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
 * @apiParam {Integer} amount la quantité à envoyer
 */
server.post('/user/:SteamID/givexp', function (req, res, next) {

  server.conn.query(server.getAuthSMAdmin, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");
    if( SteamID != "STEAM_1:0:7490757" && SteamID != "STEAM_1:1:39278818" && SteamID != "STEAM_1:0:23617413" && SteamID != "STEAM_1:1:114134761" && SteamID != "STEAM_1:1:114134761" )
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

    var UserName = row[0].username;
    var amount = parseInt(req.params['amount']);

    server.conn.query("INSERT INTO `rp_csgo`.`rp_users2` (`id`, `steamid`, `xp`, `pseudo`, `steamid2`) VALUES (NULL, ?, ?, ?, ?);", [req.params['SteamID'], amount, UserName, SteamID], function(err, row) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      return res.send("OK");
    });
  });

	next();
});

/**
   * @api {get} /user/:SteamID/success GetUserBySteamID
   * @apiName GetUserBySteamID
   * @apiGroup User
   * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
   */
  server.get('/user/:id/success', function (req, res, next) {
    function findSuccessById(id) {
      //successData.forEach(success => {
      for(var i = 0; i < successData.length; i++) {
        if(successData[i][0] == id) {
          return i;
        }
      }

      return -1;
    }

    if( req.params['id'] == 0 )
      return res.send(new ERR.BadRequestError("InvalidParam"));

    var cache = server.cache.get( req._url.pathname);
    if( cache != undefined ) { return res.send(cache); };

    var sql = "SELECT * FROM `rp_success` WHERE `SteamID`=? LIMIT 1;"

    server.conn.query(sql, [req.params['id']], function(err, rows) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      if( rows.length == 0 ) return res.send(new ERR.NotFoundError("UserNotFound"));

      var numb = -1;

      var obj = Object.keys(rows[0]).map( i => { 
        let success = findSuccessById([i]);

        if(success != -1) {
          numb++;

          let name = successData[success][1];
          let desc = successData[success][2];
          let need = successData[success][3];
          let max = successData[success][4];
          let count = rows[0][i].split(" ")[0];
          let achieved = rows[0][i].split(" ")[1];
          let last = rows[0][i].split(" ")[2];

          return {
            //[numb] : {
              "id": i,
              "name": name,
              "desc": desc,
              "need_to_unlock": need,
              "max_achieved": max,
              "count_to_unlock": count,
              "achieved": achieved,
              "last_achieved": last
            //}
          }
        }
      });

      server.cache.set( req._url.pathname, obj);
      return res.send(obj);
    });

    next();
  });

};
