"use strict";
exports = module.exports = function (server) {
  var request = require('request');
  var ERR = require('node-restify-errors');
  var moment = require('moment');
  var WebSocket = require('websocket').w3cwebsocket;
  
  /*var TwitchClient = require("node-twitchtv");
  var client = new TwitchClient({ client_id: "egfk3bhshu398at0nyjh34ehhzoxk19", scope: "user_read, channel_read_"});*/

  /**
   * @api {get} /live/stream GetLiveStream
   * @apiName GetLiveStream
   * @apiGroup Live
   */
  /*server.get('/live/stream', function (req, res, next) {
     return next();
     try {
        var cache = server.cache.get( req._url.pathname);
        if( cache != undefined ) return res.send(cache);
        var broadcaster = ["moyna54", "kossolax", "hipiman", "messorem_tsx", "exblast"];
        var obj = new Array();
        var done = 0;
  
        for(var i = 0; i<=broadcaster.length; i++ ) {
          client.streams({ channel: broadcaster[i] }, cb1);
        }
  
        function cb1(err, response) {
          if( response.stream ) {
            obj.push( {name: response.stream.channel.status, username: response.stream.channel.display_name, url: response.stream.channel.url, viewer: response.stream.viewers} )
          }
          done++;
          cb2();
        }
        function cb2() {
          if( done == broadcaster.length ) {
            server.cache.set( req._url.pathname, obj);
            return res.send(obj);
          }
        }
    } catch ( err ) {
      return res.send(obj);
    }
    next();
  });*/

  var lastReconnect;

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
      reconnect();
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


  (function reconnect() {
    if((new Date() - lastReconnect)/1000 > 4){
      return;
    }
    if (serverWs) {
      serverWs.onerror = () => { };
      serverWs.close();
      serverWs = null;
    }
    lastReconnect = new Date();
    console.log("Connecting to server websocket");
    let tmpWs = new WebSocket("ws://5.196.39.50:27020");
    serverWs.onopen = ()=>{
      serverWs = tmpWs;
    };
    tmpWs.onerror = () => { setTimeout(reconnect, 4000) };
    tmpWs.onmessage = wsMessage;
  })();


  /**
   * @api {get} /live/positions GetLivePosition
   * @apiName GetLivePosition
   * @apiGroup Live
   */
  server.get('/live/positions', function (req, res, next) {
    var cache = server.cache.get(req._url.pathname);
    if (cache != undefined) return res.send(cache);

    var wednesday = moment().startOf('week').add(3, 'days').add(18, 'hours').add(30, 'minutes');
    var friday = moment().startOf('week').add(5, 'days').add(21, 'hours').add(30, 'minutes');
    var now = moment();
    var limitation = moment().add(35, 'minutes');
    var matched = false;

    /*if( (now < wednesday && limitation > wednesday) || ( now < friday && limitation > friday ) ) {
      var data = new Array();
      server.cache.set( req._url.pathname, data);
      return res.send(data);
    }*/

    wsRequest("/location", function (error, response, body) {
      if (error) return res.send(new ERR.NotFoundError("ServerNotFound"));

      server.cache.set(req._url.pathname, body, 0.1);
      res.send(body);
      return next();
    });
    next();
  });

  server.get('/live/msg/:id', function (req, res, next) {
    if( req.connection.remoteAddress != "5.196.39.48") return res.send(new ERR.NotFoundError("ServerNotFound"));

    wsRequest("/msg/" + req.params["id"], function (error, response, body) {
      if (error) return res.send(new ERR.NotFoundError("ServerNotFound"));
      return res.send(body);
    });

    next();
  });


  /**
   * @api {get} /live/connected/:steamid GetLiveConnexion
   * @apiName GetLiveConnexion
   * @apiParam {String} steamid Un identifiant unique correspondant au steamid.
   * @apiGroup Live
   */
  server.get('/live/connected/:id', function (req, res, next) {
    var cache = server.cache.get(req._url.pathname);
    if (cache != undefined) return res.send(cache);

    var steamid = req.params['id'].trim();
    //var pattern = /^STEAM_1:[01]:[0-9]{1,18}$/g;
    var pattern = /^[0-9]{17}$/g;
    if (!pattern.test(steamid)) { return res.send(new ERR.BadRequestError("InvalidParam")); }


    wsRequest("/connected/" + steamid, function (error, response, body) {
      if (error) return res.send(new ERR.NotFoundError("ServerNotFound"));
      server.cache.set(req._url.pathname, body, 1);
      return res.send(body);
    });
    next();
  });
  /**
   * @api {get} /live/stats GetServerStats
   * @apiName GetServerStats
   * @apiGroup Live
   */
  server.get('/live/stats', function (req, res, next) {
    var cache = server.cache.get(req._url.pathname);
    if (cache != undefined) return res.send(cache);

    function cb(obj) {
      if (Object.keys(obj).length == 4) {
        server.cache.set(req._url.pathname, obj);
        return res.send(obj);
      }
    }

    var obj = new Object();
    wsRequest("/time", function (error, response, body) {
        obj.time = body;
        cb(obj);
    });

    server.conn.query("SELECT `type`, R.`steamid`, `name` FROM `rp_rank` R INNER JOIN `rp_users` U ON U.`steamid`=R.`steamid` WHERE `rank`=1", function (err, rows) {
      obj.stats = new Object();

      var tmp = { "pvp": "PvP", "sell": "Vente", "buy": "Achat", "money": "Richesse", "age": "Ancienneté", "parrain": "Parrainage", "vital": "Vitalité", "success": "Succès", "freekill": "Free-kill/mois", "freekill2": "Free-kill/31j", "general": "Général", "artisan": "Artisanat", "quest": "Quêtes", "jeton": "Jetons bleus", "level": "NiveauRP" };
      for (var i = 0; i < rows.length; i++)
        obj.stats[rows[i].type] = { steamid: rows[i].steamid, name: rows[i].name, type: tmp[rows[i].type] };
      cb(obj);
    });

    var sql = "SELECT G.`id` as `bunker`, G.`name` as `bunkerNom`, U.`steamid` as `villa`, U.`name` AS `villaNom`, U2.`steamid` as `maire`, U2.`name` AS `maireNom` ";
    sql += "FROM `rp_servers` S LEFT JOIN `rp_groups` G ON G.`id`=S.`bunkerCap` LEFT JOIN `rp_users` U ON U.`steamid`=S.`villaOwner` LEFT JOIN `rp_users` U2 ON U2.`steamid`=S.`maire` WHERE S.`id`=1";

    console.log(sql);
    server.conn.query(sql, function (err, rows) {
      obj.pvp = {};
      obj.pvp["villa"] = { id: rows[0].villa, nom: rows[0].villaNom, type: "La villa" };
      obj.pvp["bunker"] = { id: rows[0].bunker, nom: rows[0].bunkerNom, type: "Le bunker" };
      obj.pvp["maire"] = { id: rows[0].maire, nom: rows[0].maireNom, type: "Le maire" };

      cb(obj);
    });

    server.conn.query("SELECT 100000+COUNT(`id`)*420 as cagnotte FROM `rp_loto`;", function (err, rows) {
      obj.cagnotte = new Array();
      obj.cagnotte.push(rows[0].cagnotte / 100.0 * 70.0);
      obj.cagnotte.push(rows[0].cagnotte / 100.0 * 20.0);
      obj.cagnotte.push(rows[0].cagnotte / 100.0 * 10.0);
      cb(obj);
    });

    next();
  });
  /**
   * @api {get} /live/stats/:ip/:port Get Bf Information
   * @apiName Get Bf Information
   * @apiParam {String} IP
   * @apiParam {Integer} port
   * @apiGroup Live
   */
  server.get('/live/bf/:ip/:port', function (req, res, next) {
    function formatDate(time) {
      var months_arr = ['Janvier', 'Fevrier', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Decembre'];

      var date = new Date(time * 1000);
      var year = date.getFullYear();
      var month = months_arr[date.getMonth()];
      var day = date.getDate();

      return day + ' ' + month + ' ' + year;
    }

    function endDate(time) {
      var date = new Date(time * 1000);
      date.setHours(0);
      date.setMinutes(1);
      date.setSeconds(0);

      return date;
    }

    if (!req.params['ip'] || !req.params['port']) {
      return res.send(new ERR.BadRequestError("InvalidParam"));
    }

    var cache = server.cache.get(req._url.pathname);
    if (cache != undefined) { return res.send(cache); };

    var sql = "SELECT `bf_date`, `bf_reduction` FROM `rp_servers` WHERE `ip`=? AND `port`=?;";

    server.conn.query(sql, [req.params["ip"], req.params["port"]], function (err, rows) {
      if (err) return res.send(new ERR.InternalServerError(err));
      if (rows.length == 0) return res.send(new ERR.NotFoundError("ServerNotFound"));

      var obj = {
        start_date: rows[0].bf_date,
        start_date_f: formatDate(rows[0].bf_date),
        end_date: rows[0].bf_date + 86400,
        end_date_f: formatDate(rows[0].bf_date + 86400),
        reduction: rows[0].bf_reduction
      };

      server.cache.set(req._url.pathname, obj);
      return res.send(obj);
    });
    next();
  });

  /**
   * @api {get} /live/bf GetServerInformations
   * @apiName GetServerInformations
   * @apiParam {String} IP
   * @apiParam {Integer} port
   * @apiGroup Live
   */
  server.get('/live/stats/:ip/:port', function (req, res, next) {
    try {
      server.conn.query("SELECT CONCAT(`current`, '/', `maxplayers`) as p FROM `ts-x`.`adm_serv` WHERE `ip`=? AND `port`=?;", [req.params["ip"], req.params["port"]], function (err, row) {
        if (err || row.length == 0) return res.send(new ERR.NotFoundError("ServerNotFound"));
        return res.send(row[0].p);
      });
    } catch (err) {
      return res.send(err);
    }
    next();

  });

  /**
   * @api {get} /live/sondage/:steamid HasVoted
   * @apiName HasVoted
   * @apiParam {Steamid} steamid
   * @apiGroup Live
   */
  server.get('/live/sondage/:steamid', function (req, res, next) {
    return res.send("2");
    try {
      var steamid = req.params["steamid"].replace("STEAM_1", "STEAM_0");
      if (steamid == "notset" || steamid.length <= 5) return res.send("2");

      server.conn.query("SELECT * FROM `rp_report`.`site_sondage` WHERE `steamid`=? AND `time`+(20*24*60*60) > UNIX_TIMESTAMP() LIMIT 1;", [steamid], function (err, row) {
        if (err) return res.send("2");
        if (row.length == 0) return res.send("0");
        return res.send("1");
      });
    } catch (err) {
      return res.send("2");
    }
    next();

  });


  /**
   * @api {get} /live/update GetLastUpdate
   * @apiName GetLastUpdate
   * @apiGroup Live
   */
  server.get('/live/update', function (req, res, next) {
    var cache = server.cache.get(req._url.pathname);
    if (cache != undefined) return res.send(cache);

    var data = new Array();
    var done = 0;
    var subRequest = 0;
    var subRequestDone = 0;
    var tokken = server.gitTokken;

    function output() {
      subRequestDone++;
      if (done == 5 && subRequestDone == subRequest) {
        data.sort(function (a, b) { return new Date(b.date) - new Date(a.date); });
        server.cache.set(req._url.pathname, data, 300);
        return res.send(data);
      }
    }
    function getFileName(str) {
      return str.split('\\').pop().split('/').pop();
    }

    function traitement(error, response, body) {
      try {
        body = JSON.parse(body);
        console.log(body);
        body.forEach(function (i) {
          request({ url: i.url + "?access_token=" + tokken, headers: { 'User-Agent': 'kossolax' } }, function (error, response, body) {
            body = JSON.parse(body);

            var file = "";
            var change = 0;
            body.files.forEach(function (j) {
              change += j.changes;
              file += getFileName(j.filename) + ", ";
            });
            file = file.substring(0, file.length - 2);

            var obj = { author: i.author.login, date: i.commit.author.date, message: i.commit.message, files: file, changes: change };
            data.push(obj);
            output();
          });
        });
        done++;
        subRequest += body.length;
      } catch (e) {
        console.log(e);
        console.log(body);
      }
    }

    request({ url: "https://api.github.com/repos/kossolax/riplay-rp/commits?page=1", headers: { 'User-Agent': 'kossolax', 'Authorization': 'token ' +tokken } }, traitement);
    request({ url: "https://api.github.com/repos/kossolax/riplay-rp/commits?page=2", headers: { 'User-Agent': 'kossolax', 'Authorization': 'token ' +tokken } }, traitement);
    request({ url: "https://api.github.com/repos/kossolax/riplay-rp/commits?page=3", headers: { 'User-Agent': 'kossolax', 'Authorization': 'token ' +tokken } }, traitement);
    request({ url: "https://api.github.com/repos/kossolax/riplay-rp/commits?page=4", headers: { 'User-Agent': 'kossolax', 'Authorization': 'token ' +tokken } }, traitement);
    request({ url: "https://api.github.com/repos/kossolax/riplay-rp/commits?page=5", headers: { 'User-Agent': 'kossolax', 'Authorization': 'token ' +tokken } }, traitement);

    next();
  });


};
