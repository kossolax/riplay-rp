"use strict";
exports = module.exports = function(server) {
  var ERR = require('node-restify-errors');
  var moment = require('moment');


/**
 * @api {get} /groups GetGroups
 * @apiName GetGroups
 * @apiGroup Groups
 */
server.get('/groups', function (req, res, next) {
  if( req.params['jobid'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) return res.send(cache);

  server.conn.query("SELECT `id`, SUBSTRING(`name`, LOCATE(' - ', `name`)+3) as `name`, `color`, `stats` FROM `rp_groups` WHERE `is_chef`='1' ORDER BY `stats` DESC;", function(err, rows) {
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("GroupNotFound"));

    server.cache.set( req._url.pathname, rows);
    return res.send( rows );
  });

	next();
});
/**
 * @api {get} /group/:id GetGroupsById
 * @apiName GetGroupsById
 * @apiParam {Integer} id Un identifiant unique correspondant au groupe.
 * @apiGroup Groups
 */
server.get('/group/:id', function (req, res, next) {

   function cb(obj) {
     if( Object.keys(obj).length == 2 ) {
       var obj2 = obj.Data[0];
       obj2.sub = obj.List;

       server.cache.set( req._url.pathname, obj2);
       return res.send(obj2);
     }
   }
   var cache = server.cache.get( req._url.pathname);
   if( cache != undefined ) return res.send(cache);

   if( req.params['jobid'] == 0 )
     return res.send(new ERR.BadRequestError("InvalidParam"));

   var sql = "SELECT `id` as `id`, SUBSTRING(`name`, LOCATE(' - ', `name`)+3) as `name`, `stats`, `color`, `skin` ";
   sql += "FROM `rp_groups` WHERE `id`=?;"
   var obj = new Object();

   server.conn.query(sql, [req.params['id']], function(err, rows) {
     if( rows.length == 0 ) return res.send(new ERR.NotFoundError("GroupNotFound"));
     rows[0].skin = (require('path').basename(rows[0].skin)).replace(/[^A-Za-z]/g, '').replace(/variant.mdl/g, '').replace(/varmdl/g, '').replace("mdl", "");
     rows[0].skin = (rows[0].skin==''? 'null' : rows[0].skin);
     obj.Data = rows;
     cb(obj);
   });
   sql = "SELECT `id` as `id`, `name` as `name` FROM `rp_groups` WHERE `id`=0 OR `id`=? OR `owner`=? ORDER BY `id` ASC ";
   server.conn.query(sql, [req.params['id'], req.params['id']], function(err, rows) {
     if( rows.length == 0 ) return res.send(new ERR.NotFoundError("GroupNotFound"));
     obj.List = rows;
     cb(obj);
   });

 	next();
 });

/**
 * @api {get} /groups/:id/users GetUserByGroup
 * @apiName GetUserByGroup
 * @apiGroup Groups
 * @apiParam {Integer} id Un identifiant unique correspondant au groupe.
 */
server.get('/groups/:id/users', function (req, res, next) {

  if( req.params['jobid'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) return res.send(cache);

  var now = (new Date()) - (7*24*60*60*1000);

  server.conn.query("SELECT `steamid`, U.`name` as `nick`, LEFT(G.`name`, LOCATE(' - ', G.`name`)-1) as `name`, `is_chef`+`co_chef` as `is_admin`, `point`, UNIX_TIMESTAMP(`last_connected`) as `active` FROM `rp_users` U INNER JOIN `rp_groups` G ON G.`id`=U.`group_id` WHERE U.`group_id`>0 AND (G.`id`=? OR `owner`=?) ORDER BY G.`id` ASC", [req.params['id'], req.params['id']], function(err, rows) {
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("GroupNotFound"));
    for(var i=0; i<rows.length; i++) {
      rows[i].active = (new Date(parseInt(rows[i].active)*1000)) > now;
    }
    server.cache.set( req._url.pathname, rows);
    return res.send( rows );
  });

	next();
});


/**
 * @api {put} /group/:groupid/:steamid SetUserGroup
 * @apiName SetUserGroup
 * @apiGroup Groups
 * @apiHeader {String} auth Votre cookie de connexion.
 * @apiParam {Integer} groupid Un identifiant unique correspondant au groupe.
 * @apiParam {String} steamid Un identifiant unique correspondant au steamid.
 */
server.put('/group/:groupid/:steamid', function (req, res, next) {

  var wednesday = moment().startOf('week').add(3, 'days').add(18, 'hours').add(30, 'minutes');
  var friday = moment().startOf('week').add(5, 'days').add(21, 'hours').add(30, 'minutes');
  var now = moment();
  var limitation = moment().add(35, 'minutes');

  if( (now < wednesday && limitation > wednesday) || (now < friday && limitation > friday) )
    return res.send(new ERR.UnauthorizedError("Impossible de modifier votre gang durant la PvP"));

  if( req.params['groupid'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");
    var UserName = row[0].name;
    req.params['steamid'] = req.params['steamid'].replace("STEAM_0", "STEAM_1");

    if( SteamID == req.params["steamid"] )
        return res.send(new ERR.ForbiddenError("Vous ne pouvez pas modifier votre propre grade."));

    var sql = "SELECT U.`group_id` as `job_id`, `is_chef` as `is_boss`, `co_chef`, `owner` as `own_boss` FROM `rp_users` U INNER JOIN `rp_groups` G ON G.`id`=U.`group_id` WHERE `steamid`=?";
    server.conn.query(sql, [SteamID], function(err, row) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      if( row.length == 0 ) return res.send(new ERR.NotFoundError("Ce steamID est invalide."));

      var row1 = row[0]; // ROW1 = Le chef
      var jobID = parseInt(req.params["id"]);

      server.conn.query("SELECT `owner` as `own_boss` FROM `rp_groups` WHERE `id`=?", [jobID], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row.length == 0 ) return res.send(new ERR.NotFoundError("Ce groupID est invalide"));

        var uniqID = parseInt(row[0].own_boss);

        if( uniqID == 0 && jobID != 0)
            return res.send(new ERR.ForbiddenError("Vous n'avez pas les permissions suffisantes pour ce rang."));
        if( parseInt(row1.job_id) == 0 || (parseInt(row1.is_boss) == 0 && parseInt(row1.co_chef) == 0) )
            return res.send(new ERR.ForbiddenError("Vous n'avez pas les permissions suffisantes pour ce rang."));
        if( jobID > 0 && parseInt(row1.job_id) != uniqID )
          if( parseInt(row1.own_boss) != uniqID )
            return res.send(new ERR.ForbiddenError("Vous ne faites pas autorité sur ce joueur. Celui-ci doit quitter son groupe en premier."));

        server.conn.query(sql, [req.params["steamid"]], function(err, row) {
          if( err ) return res.send(new ERR.InternalServerError(err));
          if( row.length == 0 ) return res.send(new ERR.NotFoundError("Ce groupID est invalide"));

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

          server.conn.query("SELECT COUNT(`group_id`) as `cpt` FROM `rp_users` U INNER JOIN `rp_groups` G ON G.`id`=U.`group_id` WHERE (G.`id`=? OR G.`owner`=?) AND U.`steamid`<>? ;", [uniqID, uniqID, req.params["steamid"]], function(err, row) {
            if( jobID != 0 && parseInt(row[0].cpt) >= 6 )
              return res.send(new ERR.ForbiddenError("Impossible de recruter plus de 6 personnes dans votre groupe."));

            server.conn.query("UPDATE `rp_users` SET `group_id`=? WHERE `steamid`=? LIMIT 1;", [jobID, req.params["steamid"]], function(err, row) {
              if( err ) return res.send(new ERR.InternalServerError(err));
              server.conn.query("INSERT INTO `rp_users2` (`id`, `steamid`, `group_id`, `pseudo`, `steamid2`) VALUES (NULL, ?, ?, ?, ?);", [req.params["steamid"], jobID, UserName, SteamID], function(err, row) {
                if( err ) return res.send(new ERR.InternalServerError(err));

                server.cache.del("/groups/"+uniqID+"/users");
                server.cache.del("/user/"+req.params["steamid"]);
                return res.send("OK");
              });
            });
          });
        });
      });
    });
  });

  next();
});

};
