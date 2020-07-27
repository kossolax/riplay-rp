"use strict";
exports = module.exports = function(server){
  var ERR = require('node-restify-errors');
  var moment = require('moment');
  var gd = require('node-gd');
  var fs = require('fs');
  var wrap = require('wordwrap')(60);

/**
 * @api {post} /forum/pm/:id SendUserPM
 * @apiName SendUserPM
 * @apiGroup Forum
 * @apiHeader {String} auth Votre cookie de connexion.
 * @apiParam {Integer} id Un identifiant unique correspondant à l'userID forum.
 * @apiParam {String} title Le titre du message à envoyer
 * @apiParam {String} message Le message en lui même.
 */
/*

*/
/*server.post('/forum/pm/:id', function (req, res, next) {

  try {
    req.params['id'] = parseInt(req.params['id']);

    if( req.params['id'] == 0 )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
      if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      var uid = row[0].user_id;

      var sql = "INSERT INTO `ts-x`.`phpbb3_privmsgs`(`msg_id`, `author_id`, `author_ip`, `message_time`, `message_subject`, `message_text`, `to_address`, `bcc_address`) VALUES";
      sql += "  (NULL, '"+uid+"', '0.0.0.0', UNIX_TIMESTAMP(), ?, ?, 'u_"+req.params['id']+"', '');"

      server.conn.query(sql, [req.params['title'], req.params['message']], function(err, row) {
        var ID = row.insertId;

        sql = "INSERT INTO `ts-x`.`phpbb3_privmsgs_to`(`msg_id`, `user_id`, `author_id`, `pm_new`, `pm_unread`) VALUES ";
        sql += " (?, ?, ?, '1', '1');"
        server.conn.query(sql, [ID, req.params['id'], uid], function(err, row) {

          sql = "UPDATE `ts-x`.`phpbb3_users` SET `user_new_privmsg`=`user_new_privmsg`+1, `user_unread_privmsg`=`user_unread_privmsg`+1, `user_last_privmsg`=UNIX_TIMESTAMP() WHERE `user_id`=?";
          server.conn.query(sql, [req.params['id']], function(err, row) {
            return res.send("OK");
          });
        });
      });
    });

  } catch ( err ) {
    return res.send(err);
  }
  next();
});*/

/**
 * @api {get} /forum/pm GetAllUserPM
 * @apiName GetAllUserPM
 * @apiGroup Forum
 * @apiHeader {String} auth Votre cookie de connexion.
 */
/*server.get('/forum/pm', function (req, res, next) {
  try {
    server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
      if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      var uid = row[0].user_id;

      var sql = "SELECT `msg_id`, `author_id`, `author_ip`, `message_time`, `message_subject`, `message_text`, `to_address` FROM `ts-x`.`phpbb3_privmsgs` WHERE to_address = ? ORDER BY `message_time` DESC ;";
      server.conn.query(sql, ["u_"+uid], function(err, row) {
        return res.send(row);
      });
    });
  } catch ( err ) {
    return res.send(err);
  }
  next();
});*/

/**
 * @api {get} /forum/user/id/:username GetIdUser
 * @apiName GetIdUser
 * @apiGroup Forum
 * @apiHeader {String} auth Votre cookie de connexion.
 * @apiParam {String} pseudo forum de l'utilisateur.
 */
/*

*/
/*server.get('/forum/user/id/:username', function (req, res, next) {
  try {
    if( req.params['username'] == "" )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
      if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      var uid = row[0].user_id;

      var username_clean = req.params['username'].toLowerCase();

      var sql = "SELECT `user_id` FROM `ts-x`.`phpbb3_users` WHERE username_clean = ?;";
      server.conn.query(sql, [username_clean], function(err, row) {
        if( err ) throw err;
        if( row[0] == null ) return res.send(new ERR.NotFoundError("NotFound"));
        return res.send(row[0].user_id);
      });
    });
  } catch ( err ) {
    return res.send(err);
  }
  next();
});*/

/**
 * @api {get} /forum/user/pm/unread GetCountUnreadPM
 * @apiName GetCountUnreadPM
 * @apiGroup Forum
 * @apiHeader {String} auth Votre cookie de connexion.
 */
/*

*/
/*server.get('/forum/user/pm/unread', function (req, res, next) {
  try {
    server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
      if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      var uid = row[0].user_id;

      var sql = "SELECT `user_unread_privmsg` FROM `ts-x`.`phpbb3_users` WHERE user_id = ?;";
      server.conn.query(sql, [uid], function(err, row) {
        return res.send(""+row[0].user_unread_privmsg);
      });
    });
  } catch ( err ) {
    return res.send(err);
  }
  next();
});

server.get('/forum/announcement/:id', function (req, res, next) {
  try {
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


    if( req.params['id'] == 0 ) return res.send(new ERR.BadRequestError("InvalidParam"));
    server.conn.query("SELECT CONVERT(`text` USING utf32) as `text` FROM `ts-x`.`site_annonces` WHERE `id`=?", [req.params['id']], function(err, row) {

      var text = wrap(row[0].text);

      var cache = "/var/www/ts-x/cache/announcement/"+req.params['id']+".jpg";
      var police = "/var/www/ts-x/fonts/NotoSans-Regular.ttf";
      var size = 12;
      var img = gd.createSync(1, 1);
      var black = img.colorAllocate(0,0,0);
      var length = img.stringFTBBox(black, police, size, 0, 0, 0, text);
      img.destroy();

      var img = gd.createSync(500, length[1]+20+size);
      var white = img.colorAllocate(255,255,255);
      var black = img.colorAllocate(0,0,0);
      img.stringFT(black, police, size, 0, 10, size+10, text);

      img.saveJpeg(cache, 100, function(err, bla) {
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
  }
  catch ( err ) {
   return res.send(err);
  }
});*/

/**
 * @api {get} /forum/user/pm/new GetCountNewPM
 * @apiName GetCountNewPM
 * @apiGroup Forum
 * @apiHeader {String} auth Votre cookie de connexion.
 */
/*

*/
/*server.get('/forum/user/pm/new', function (req, res, next) {
  try {
    server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
      if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      var uid = row[0].user_id;

      var sql = "SELECT `user_new_privmsg`, `user_unread_privmsg` FROM `ts-x`.`phpbb3_users` WHERE user_id = ?;";
      server.conn.query(sql, [uid], function(err, row) {
        return res.send(""+row[0].user_new_privmsg);
      });
    });
  } catch ( err ) {
    return res.send(err);
  }
  next();
});*/

/**
 * @api {get} /forum/post/last GetLastPost
 * @apiName GetLastPost
 * @apiGroup Forum
 * @apiHeader {String} auth Votre cookie de connexion.
 */
/*server.get('/forum/post/last', function (req, res, next) {
  try {
    server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
      if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      var uid = row[0].user_id;

      var sql = "SELECT `post_id`,`post_subject`,`post_text` FROM `ts-x`.`phpbb3_posts` AS P INNER JOIN `ts-x`.`phpbb3_users` AS U ON U.`user_id`=P.`poster_id`WHERE `forum_id` IN (10, 30, 53, 54, 56, 57, 147, 72, 12, 16, 5, 103, 35, 117, 83, 84, 86, 88, 94, 95, 11) AND LENGTH(`post_text`)>20 ORDER BY `post_time` DESC LIMIT 10;";
      server.conn.query(sql, function(err, row) {
        return res.send(row);
      });
    });
  } catch ( err ) {
    return res.send(err);
  }
  next();
});*/

/**
 * @api {put} /forum/bulb PutBulbDown
 * @apiName PutBulbDown
 * @apiGroup Forum
 * @apiHeader {String} auth Votre cookie de connexion.
 */
/*server.put('/forum/bulb', function (req, res, next) {
  try {
    server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
      if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      server.conn.query("UPDATE `ts-x`.`phpbb3_users` SET `bulb`=`bulb`+1 WHERE `user_id`=?;", [row[0].user_id], function(err, row) {
        return res.send(row);
      });
    });
  } catch ( err ) {
    return res.send(err);
  }
  next();
});*/

/**
 * @api {get} /forum/smiley GetSmiley
 * @apiName GetSmiley
 * @apiGroup Forum
 * @apiHeader {String} auth Votre cookie de connexion.
 */
/*server.get('/forum/smiley', function (req, res, next) {
  try {
  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var uid = row[0].user_id;

    var sql = "SELECT `code`,`smiley_url`,`smiley_width`,`smiley_height` FROM `ts-x`.`phpbb3_smilies`;";
    server.conn.query(sql, [], function(err, row) {
      return res.send(row);
    });
  });
  } catch ( err ) {
    return res.send(err);
  }
  next();
});*/


/**
 * @api {get} /forum/download GetAllUserPM
 * @apiName GetAllDownload
 * @apiGroup Forum
 * @apiHeader {String} auth Votre cookie de connexion.
 */
/*server.get('/forum/download', function (req, res, next) {
  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) return res.send(cache);
  server.conn.query("SELECT `path` FROM `rp_csgo`.`rp_download`;", function(err, row) {

    var obj = new Array();
    for(var i=0; i<row.length; i++)
      obj.push(row[i].path);

    server.cache.set( req._url.pathname, obj);
    return res.send(obj);
  });
  next();
});*/

/**
 * @api {get} /forum/steamid GetUserSteamID
 * @apiName GetUserSteamID
 * @apiGroup Forum
 * @apiHeader {String} auth Votre cookie de connexion.
 */
server.get('/forum/steamid', function (req, res, next) {
  try {
    server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
      /*console.log(server.getAuthSteamID);
      console.log(req.headers.auth);*/
      if( row.length == 0 ) {
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      }

      return res.send(row[0].steamid.replace("STEAM_0", "STEAM_1"));
    });
  } catch ( err ) {
    return res.send(err);
  }
  next();
});

server.get('/forum/testadmin', function (req, res, next) {
  try {
    server.conn.query(server.getAuthAdminID, [req.headers.auth], function(err, row) {
     console.log(server.getAuthAdminID);
      console.log(req.headers.auth);
      if( row.length == 0 ) {
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      }

      return "Hello " + res.send(row[0].name) + " you are in root group";
    });
  } catch ( err ) {
    return res.send(err);
  }
  next();
});

};
