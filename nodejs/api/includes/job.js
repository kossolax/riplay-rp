"use strict";
exports = module.exports = function(server) {
  var ERR = require('node-restify-errors');
  var ratioMulti = 0.8;


/**
 * @api {get} /jobs GetJobs
 * @apiName GetJobs
 * @apiGroup Jobs
 */
server.get('/jobs', function (req, res, next) {

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) { return res.send(cache); }

  var sql = "SELECT J.`job_id` as `id`, SUBSTRING(`job_name`, LOCATE(' - ', `job_name`)+3) as `name`, FLOOR(`quota`*"+ratioMulti+") as `quota`, `current`, `steamid`, `approuved`";
	sql += " FROM `rp_jobs` J";
  sql += " LEFT JOIN (";
  sql += " SELECT `steamid`, `job_id` FROM `rp_users` U WHERE `job_id`>0 AND UNIX_TIMESTAMP(`last_connected`)>UNIX_TIMESTAMP()-(7*24*60*60) AND `time_played`>=(DAY(NOW())/2)";
  sql += " ) as U ON U.`job_id`=J.`job_id`";
  sql += " WHERE `is_boss`='1'";
  sql += " GROUP BY J.`job_id`";
  server.conn.query(sql, function(err, rows) {
    server.cache.set( req._url.pathname, rows, 300);
    return res.send( rows );
  });

  next();
});


/**
 * @api {get} /job/:id/top GetJobTop
 * @apiName GetJobTop
 * @apiGroup Jobs
 * @apiParam {Integer} jobid Un identifiant unique correspondant au job.
 */
server.get('/job/:id/top', function (req, res, next) {

  var id = parseInt(req.params['id']);
  if( isNaN(id) || typeof id !== 'number' || id <= 0 || id >= 230 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) return res.send(cache);

  var sql = "SELECT U.`steamid`, SUM(`total`) AS `total`, `name` FROM ( ";
  sql += "    SELECT `steamid`, SUM(I.`prix`*S.`amount`) AS `total` FROM `rp_sell` S";
  sql += "    INNER JOIN `rp_items` I ON S.`item_id`=I.`id`";
  sql += "    WHERE S.`job_id`='"+id+"' AND `item_type`='0' GROUP BY `steamid`";
  sql += "    UNION";
  sql += "    SELECT `steamid`, SUM(`total`) as `total` FROM ( ";
  sql += "        SELECT `steamid`, SUM(S.`amount`) AS `total` FROM `rp_sell` S";
  sql += "        WHERE S.`job_id`='"+id+"' AND (`item_type`='2' OR (`item_type`='4' AND `item_name`='Vol: Objet'))";
  sql += "        GROUP BY `steamid`";
  sql += "        UNION ";
  sql += "        SELECT `steamid`, SUM(`amount`) AS `total`";
  sql += "        FROM `rp_sell` WHERE `job_id`='"+id+"' AND `item_id`='0' AND `item_name` LIKE 'Vol: %'";
  sql += "        GROUP BY `steamid`";
  sql += "    ) AS VOL GROUP BY `steamid`";
  sql += "    UNION";
  sql += "    SELECT `steamid`, SUM(`amount`) AS `total` FROM `rp_sell`";
  sql += "    WHERE `job_id`='"+id+"' AND (`item_type`='3' OR (`item_type`='4' AND (`item_name`='Caution' OR `item_name`='Amande')))";
  sql += "    GROUP BY `steamid`";
  sql += " ) AS P INNER JOIN `rp_users` U ON U.`steamid` = P.`steamid` ";
  sql += " INNER JOIN `rp_jobs` J ON J.`job_id`=U.`job_id` ";
  sql += " WHERE J.`job_id`='"+id+"' OR J.`own_boss`='"+id+"' GROUP BY `steamid` ORDER BY `total` DESC;";



  server.conn.query(sql, function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));

    server.cache.set( req._url.pathname, rows);
    return res.send(rows);
  });

  next();
});
/**
 * @api {post} /job/:SteamID/approuve giveClientItem
 * @apiName giveClientItem
 * @apiGroup User
 * @apiParam {String} SteamID Un identifiant unique sous le format STEAM_1:x:xxxxxxx
 * @apiParam {Integer} itemid Identifiant unique de l'item à envoyer
 * @apiParam {Integer} amount la quantité à envoyer
 */
server.put('/job/:id/approuve', function (req, res, next) {

  server.conn.query(server.getAuthSMAdmin, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");
    if( SteamID != "76561198018935404" ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

     server.conn.query("UPDATE `rp_notes` SET `approuved` = '1' WHERE `job_id` = ?;", [req.params['id']], function(err, row) {
	server.conn.query("UPDATE `rp_jobs` SET `approuved` = '1' WHERE `job_id` = ?;", [req.params['id']], function(err, row) {
	      if( err ) return res.send(new ERR.InternalServerError(err));
	      return res.send("OK");
    	});
     });
  });

	next();
});

/**
 * @api {put} /job/:jobid/:steamid SetUserJob
 * @apiName SetUserJob
 * @apiGroup Jobs
 * @apiHeader {String} auth Votre cookie de connexion.
 * @apiParam {Integer} jobid Un identifiant unique correspondant au job.
 * @apiParam {String} steamid Un identifiant unique correspondant au steamid.
 */
server.put('/job/:jobid/:steamid', function (req, res, next) {
  if( req.params['jobid'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {

    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");
    var UserName = row[0].username_clean;
    req.params['steamid'] = req.params['steamid'].replace("STEAM_0", "STEAM_1");

    if( SteamID == req.params["steamid"] )
        return res.send(new ERR.ForbiddenError("Vous ne pouvez pas modifier votre propre grade."));

    var sql = "SELECT U.`job_id`, `is_boss`, `co_chef`, `own_boss` FROM `rp_users` U INNER JOIN `rp_jobs` J ON J.`job_id`=U.`job_id` WHERE `steamid`=?";
    server.conn.query(sql, [SteamID], function(err, row) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      if( row.length == 0 ) return res.send(new ERR.NotFoundError("Ce steamID est invalide."));

      var row1 = row[0]; // ROW1 = Le chef
      var jobID = parseInt(req.params["id"]);

      server.conn.query("SELECT `own_boss` FROM `rp_jobs` WHERE `job_id`=?", [jobID], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row.length == 0 ) return res.send(new ERR.NotFoundError("Ce jobID est invalide"));

        var uniqID = parseInt(row[0].own_boss);
        if( uniqID == 0 && jobID != 0)
            return res.send(new ERR.ForbiddenError("Vous n'avez pas les permissions suffisantes pour ce rang."));
        if( parseInt(row1.job_id) == 0 || (parseInt(row1.is_boss) == 0 && parseInt(row1.co_chef) == 0) )
            return res.send(new ERR.ForbiddenError("Vous n'avez pas les permissions suffisantes pour ce rang."));
        if( jobID > 0 && parseInt(row1.job_id) != uniqID )
          if( parseInt(row1.own_boss) != uniqID )
            return res.send(new ERR.ForbiddenError("Vous ne faites pas autorité sur ce joueur. Celui-ci doit quitter son job en premier."));

        server.conn.query(sql, [ req.params['steamid'] ], function(err, row) {
          if( err ) return res.send(new ERR.InternalServerError(err));
          if( row.length == 0 ) return res.send(new ERR.NotFoundError("Ce jobID est invalide"));

          var row2 = row[0]; // ROW2 = Le futur employé

          if( parseInt(row2.is_boss) == 1 )
            return res.send(new ERR.ForbiddenError("Vous n'avez pas les permissions suffisantes pour ce rang."));
          if( jobID>0 && parseInt(row2.job_id) != 0 && parseInt(row2.own_boss) != uniqID )
              return res.send(new ERR.ForbiddenError("Vous ne faites pas autorité sur ce joueur. Celui-ci doit quitter son groupe en premier."));
          if( jobID==0 && parseInt(row2.own_boss) != parseInt(row1.own_boss) )
            if( parseInt(row2.own_boss) != parseInt(row1.job_id) )
              return res.send(new ERR.ForbiddenError("Vous ne faites pas autorité sur ce joueur. Celui-ci doit quitter son groupe en premier."));

          if( jobID != 0 && jobID <= row1.job_id )
            return res.send(new ERR.ForbiddenError("Vous n'avez pas les permissions suffisantes pour ce rang."));
          if( row2.job_id == row1.job_id )
              return res.send(new ERR.ForbiddenError("Vous n'avez pas les permissions suffisantes pour ce rang."));

          server.conn.query("UPDATE `rp_users` SET `job_id`=? WHERE `steamid`=? LIMIT 1;", [jobID, req.params["steamid"]], function(err, row) {
            if( err ) return res.send(new ERR.InternalServerError(err));
            server.conn.query("INSERT INTO `rp_users2` (`id`, `steamid`, `job_id`, `pseudo`, `steamid2`) VALUES (NULL, ?, ?, ?, ?);", [req.params["steamid"], jobID, UserName, SteamID], function(err, row) {
              if( err ) return res.send(new ERR.InternalServerError(err));

              server.cache.del("/jobs/"+uniqID+"/users");
              server.cache.del("/user/"+req.params["steamid"]);
              return res.send("OK");
            });
          });
        });
      });
    });
  });

  next();
});

/**
 * @api {get} /job/:id GetJobsById
 * @apiName GetJobsById
 * @apiGroup Jobs
 * @apiParam {Integer} id Un identifiant unique correspondant au job.
 */
server.get('/job/:id', function (req, res, next) {

  function cb(obj) {
    if( Object.keys(obj).length == 4 ) {
      var obj2 = obj.Data[0];
      obj2.sub = obj.List;
      obj2.zones = obj.zones;
      obj2.notes = obj.notes;

      server.cache.set( req._url.pathname, obj2);
      return res.send(obj2);
    }
  }

  if( req.params['jobid'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) return res.send(cache);

  var sql = "SELECT `job_id` as `id`, SUBSTRING(`job_name`, LOCATE(' - ', `job_name`)+3) as `name`, `capital`, `subside`, FLOOR(`quota`*"+ratioMulti+") as `quota`, `current`, `approuved` ";
  sql += "FROM `rp_jobs` WHERE `job_id`=?;"
  var obj = new Object();

  server.conn.query(sql, [req.params['id']], function(err, rows) {
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("JobNotFound"));
    obj.Data = rows;
    cb(obj);
  });

  sql = "SELECT `job_id` as `id`, `job_name` as `name`, `pay` FROM `rp_jobs` WHERE `job_id`=0 OR `job_id`=? OR `own_boss`=? ORDER BY `id` ASC ";
  server.conn.query(sql, [req.params['id'], req.params['id']], function(err, rows) {
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("JobNotFound"));
    obj.List = rows;
    cb(obj);
  });

  sql = "SELECT `zone_name` as `name` FROM `rp_location_zones` Z INNER JOIN `rp_jobs` J ON J.`job_id`=Z.`zone_type` WHERE J.`job_id`=? AND Z.`private`='0' ORDER BY `id` ASC ";
  server.conn.query(sql, [req.params['id']], function(err, rows) {
    obj.zones = rows;
    cb(obj);
  });

  sql = "SELECT `id`, `txt` as `name`, `approuved` FROM `rp_notes` WHERE `job_id`=? AND `hidden`='0' ORDER BY `id`-`priority` ASC ";
  server.conn.query(sql, [req.params['id']], function(err, rows) {
    obj.notes = rows;
    cb(obj);
  });

	next();
});
/**
 * @api {get} /jobs/:id/users GetUserByJob
 * @apiName GetUserByJob
 * @apiGroup Jobs
 * @apiParam {Integer} id Un identifiant unique correspondant au job.
 */
server.get('/jobs/:id/users', function (req, res, next) {

  if( req.params['jobid'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) return res.send(cache);

  var now = (new Date()) - (7*24*60*60*1000);

  server.conn.query("SELECT `steamid`, `name` as `nick`, `job_name` as `name`, U.`job_id`, `is_boss`+`co_chef` as `is_admin`, UNIX_TIMESTAMP(`last_connected`) as `active`, `TimePlayedJob` FROM rp_csgo.`rp_users` U INNER JOIN rp_csgo.`rp_jobs` J ON J.`job_id`=U.`job_id` WHERE U.`job_id`>0 AND (J.`job_id`=? OR `own_boss`=?) ORDER BY U.`job_id` ASC", [req.params['id'], req.params['id']], function(err, rows) {
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("JobNotFound"));
    for(var i=0; i<rows.length; i++) {
      rows[i].active = (new Date(parseInt(rows[i].active)*1000)) > now;
    }
    server.cache.set( req._url.pathname, rows);
    return res.send( rows );
  });

	next();
});


/**
 * @api {post} /job/:jobid/note/:id EditJobNote
 * @apiName EditJobNote
 * @apiGroup Jobs
 * @apiParam {Integer} jobid Un identifiant unique correspondant au job
 * @apiParam {Integer} id Un identifiant unique correspondant à la note
 * @apiParam {String} txt la nouvelle note
 */
server.post('/job/:jobid/note/:id', function (req, res, next) {

  if( req.params['id'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var sql = "SELECT `is_boss`+`co_chef` as `is_admin` FROM `rp_users` U";
  sql += " INNER JOIN `rp_jobs` J ON J.`job_id`=U.`job_id`";
	sql += " INNER JOIN `rp_notes` N ON J.`job_id`=N.`job_id`";
  sql +=  "WHERE `steamid`=? AND `id`=? AND (U.`job_id`=N.`job_id` OR J.`own_boss`=N.`job_id`);"

  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

    server.conn.query(sql, [SteamID, req.params['id']], function(err, rows) {
      if( rows.length == 0 ) return res.send(new ERR.NotFoundError("NotFound"));
      if( rows[0].is_admin != 1 )  return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

      server.conn.query("UPDATE `rp_notes` SET `txt`=?,`approuved`='0' WHERE `id`=?", [req.params['txt'], req.params['id']], function(err, rows) {
        if( rows.length == 0 ) return res.send(new ERR.NotFoundError("NotFound"));

        server.cache.del("/job/"+req.params["jobid"]);
        return res.send( "OK" );
      });
    });
  });

	next();
});
/**
 * @api {put} /job/:jobid/note/:id/:type AlterJobNote
 * @apiName AlterJobNote
 * @apiGroup Jobs
 * @apiParam {Integer} jobid Un identifiant unique correspondant au job
 * @apiParam {Integer} id Un identifiant unique correspondant à la note
 * @apiParam {String=up,down} type soit up, soit down

 */
server.put('/job/:jobid/note/:id/:type', function (req, res, next) {

  if( req.params['id'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var val = 0;
  if( req.params['type'] == 'up' )
    val = 1;
  else if( req.params['type'] == 'down' )
    val = -1;
  else
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var sql = "SELECT `is_boss`+`co_chef` as `is_admin` FROM `rp_users` U";
  sql += " INNER JOIN `rp_jobs` J ON J.`job_id`=U.`job_id`";
	sql += " INNER JOIN `rp_notes` N ON J.`job_id`=N.`job_id`";
  sql +=  "WHERE `steamid`=? AND `id`=? AND (U.`job_id`=N.`job_id` OR J.`own_boss`=N.`job_id`);"

  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

    server.conn.query(sql, [SteamID, req.params['id']], function(err, rows) {
      if( rows.length == 0 ) return res.send(new ERR.NotFoundError("NotFound"));
      if( rows[0].is_admin != 1 )  return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

      server.conn.query("UPDATE `rp_notes` SET `priority`=`priority`+? WHERE `id`=?", [val, req.params['id']], function(err, rows) {
        if( rows.length == 0 ) return res.send(new ERR.NotFoundError("NotFound"));

        server.cache.del("/job/"+req.params["jobid"]);
        return res.send( "OK" );
      });
    });
  });

	next();
});
/**
 * @api {post} /job/:jobid/note/:id EditJobNote
 * @apiName EditJobNote
 * @apiGroup Jobs
 * @apiParam {Integer} jobid Un identifiant unique correspondant au job
 * @apiParam {Integer} id Un identifiant unique correspondant à la note
 * @apiParam {String} txt la nouvelle note
 */
/*server.post('/job/:jobid/note/:id', function (req, res, next) {

  if( req.params['id'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var sql = "SELECT `is_boss`+`co_chef` as `is_admin` FROM `rp_users` U";
  sql += " INNER JOIN `rp_jobs` J ON J.`job_id`=U.`job_id`";
  sql += " INNER JOIN `rp_notes` N ON J.`job_id`=N.`job_id`";
  sql +=  "WHERE `steamid`=? AND `id`=? AND (U.`job_id`=N.`job_id` OR J.`own_boss`=N.`job_id`);"

  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

    server.conn.query(sql, [SteamID, req.params['id']], function(err, rows) {
      if( rows.length == 0 ) return res.send(new ERR.NotFoundError("NotFound"));
      if( rows[0].is_admin != 1 )  return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

      server.conn.query("UPDATE `rp_notes` SET `txt`=?,`approuved`='0' WHERE `id`=?", [req.params['txt'], req.params['id']], function(err, rows) {
        if( rows.length == 0 ) return res.send(new ERR.NotFoundError("NotFound"));

        server.cache.del("/job/"+req.params["jobid"]);
        return res.send( "OK" );
      });
    });
  });

  next();
});*/
/**
 * @api {delete} /job/:jobid/note/:id DeleteJobNote
 * @apiName DeleteJobNote
 * @apiGroup Jobs
 * @apiParam {Integer} jobid Un identifiant unique correspondant au job
 * @apiParam {Integer} id Un identifiant unique correspondant à la note
 * @apiParam {String} txt la nouvelle note
 */
server.del('/job/:jobid/note/:id', function (req, res, next) {

  if( req.params['id'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var sql = "SELECT `is_boss`+`co_chef` as `is_admin` FROM `rp_users` U";
  sql += " INNER JOIN `rp_jobs` J ON J.`job_id`=U.`job_id`";
	sql += " INNER JOIN `rp_notes` N ON J.`job_id`=N.`job_id`";
  sql +=  "WHERE `steamid`=? AND `id`=? AND (U.`job_id`=N.`job_id` OR J.`own_boss`=N.`job_id`);"

  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

    server.conn.query(sql, [SteamID, req.params['id']], function(err, rows) {
      if( rows.length == 0 ) return res.send(new ERR.NotFoundError("NotFound"));
      if( rows[0].is_admin != 1 )  return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

      server.conn.query("DELETE FROM `rp_notes` WHERE `id`=?", [req.params['id']], function(err, rows) {
        if( rows.length == 0 ) return res.send(new ERR.NotFoundError("NotFound"));

        server.cache.del("/job/"+req.params["jobid"]);
        return res.send( "OK" );
      });
    });
  });

	next();
});
/**
 * @api {get} /jobs/:id/capital/:scale GetJobCapital
 * @apiName GetJobCapital
 * @apiGroup Jobs
 * @apiParam {Integer} id Un identifiant unique correspondant au job.
 * @apiParam {Integer} scale échelle de temps en heure. Défaut: 24
 */
server.get('/jobs/:id/capital/:scale', function (req, res, next) {
  if( req.params['jobid'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var scale = 24;
  if( req.params['scale'] != 0 )
    scale = parseInt(req.params['scale']);

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) return res.send(cache);

  var obj = new Object();

  var sqlTimeColumn = "(FLOOR(`timestamp`/("+scale+"*60*60))*"+scale+"*60*60) as `date` ";
  var sql = "";
  sql += "SELECT AVG(`amount`) AS `total`, " + sqlTimeColumn;
  sql += "	FROM rp_csgo.`rp_sell` WHERE `steamid`='CAPITAL' AND `job_id`=? GROUP BY `date` ORDER BY `date` ASC;"

  console.log(sql);
  
  server.conn.query(sql, [req.params['id']], function(err, rows) {
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("JobNotFound"));

    var tmp = new Array();
    var min = 99999999999, max = 0;

    for (var i = 0, len = rows.length; i < len; i++) {
      tmp.push( Array( parseInt(rows[i].date)*1000 , parseInt(rows[i].total) ) );

      if( min > parseInt(rows[i].total) )
        min = parseInt(rows[i].total);
      if( max < parseInt(rows[i].total) )
          max = parseInt(rows[i].total);
    }

    var obj = new Object();
    obj.title = 'Argent du capital';
    obj.axis = { title: { text: 'Argent ($)'}, min: min, endOnTick: false, maxPadding: 0.0, minPadding: 0.0};
    obj.data = [{name: 'Argent du capital', data: tmp}];

    server.cache.set( req._url.pathname, obj);
    return res.send(obj);
  });

  next();
});


/**
 * @api {get} /jobs/avocats GetAvocats
 * @apiName GetAvocats
 * @apiGroup Jobs
 */
server.get('/jobs/avocats', function (req, res, next) {

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) { return res.send(cache); }

  var sql = "SELECT `steamid`, `name`, `avocat` AS 'honoraires' FROM `rp_users` WHERE `avocat` > 0 ORDER BY `avocat` DESC;";

  server.conn.query(sql, function(err, rows) {
    server.cache.set( req._url.pathname, rows, 300);
    return res.send( rows );
  });

  next();
});



/**
 * @api {put} /jobs/avocat/:steamid SetAvocat
 * @apiName SetAvocat
 * @apiGroup Jobs
 * @apiHeader {String} auth Votre cookie de connexion.
 * @apiParam {String} steamid Le steamid de la personne
 * @apiParam {Integer} amount Le montant des honoraires (0 = pas avocat)
 */
server.put('/jobs/avocat/:steamid', function (req, res, next) {

  if( req.params['steamid'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var sql  = "SELECT `is_boss`+`co_chef` as `is_admin`FROM `rp_users` U";
  sql     += " INNER JOIN `rp_jobs` J ON J.`job_id`=U.`job_id`";
  sql     += "WHERE `steamid`=? AND TRUNCATE(U.`job_id`,-1)=100;"

  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

    server.conn.query(sql, [SteamID], function(err, rows) {
      if( rows.length == 0 ) return res.send(new ERR.NotFoundError("NotFound"));
      if( rows[0].is_admin != 1 )  return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

      server.conn.query("UPDATE `rp_users` SET `avocat`=? WHERE `steamid`=?", [req.params['amount'], req.params['steamid']], function(err, rows) {
        if( rows.length == 0 ) return res.send(new ERR.NotFoundError("NotFound"));

        server.cache.del("/jobs/avocats");
        return res.send( "OK" );
      });
    });
  });

  next();
});

};
