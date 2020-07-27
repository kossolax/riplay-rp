"use strict";

exports = module.exports = function(server) {
var sys  = require('os-utils');
var ERR = require('node-restify-errors');
var moment = require('moment');
var child = require('child_process');
var fs = require('fs');

function encode(str, key) {
   key = require('crypto').createHash('sha1').update(key).digest("hex");
   var j = 0;
   var hash = "";
   for(var i=0; i<str.length; i++) {

     var ordStr = str.substr(i, 1).charCodeAt(0);
     if (j == key.length) { j = 0; }
     var ordKey = key.substr(j,1).charCodeAt(0);
     j++;

     hash += parseInt(ordStr+ordKey).toString(36).split('').reverse().join('');
   }

   return hash;
}

/**
 * @api {get} /panel/sys GetSystemInformation
 * @apiPermission admin
 * @apiName GetSystemInformation
 * @apiGroup Panel
 * @apiHeader {String} auth Votre cookie de connexion.
 */
server.get('/panel/sys', function (req, res, next) {
    try {
      server.conn.query(server.getAuthAdminID, [req.headers.auth], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

        var obj = new Object();
        function cb(obj) {
          if( Object.keys(obj).length == 5 ) {
            res.send(obj);
	    return next();
	  }
        }

        obj.loadavg = sys.loadavg(1);
        sys.cpuUsage( function(i) {
          obj.CPU = parseFloat(i)*100.0;

          cb(obj);
        });
        child.exec('free -m', function(error, stdout, stderr) {
          var lines = stdout.split("\n");
          var str_mem_info = lines[1].replace( /[\s\n\r]+/g,' ');
          var mem_info = str_mem_info.split(' ');
          var total_mem    = parseFloat(mem_info[1]);
          var free_mem     = parseFloat(mem_info[3]);
          var cached_mem   = parseFloat(mem_info[6]);

          obj.memory = (1-((free_mem+cached_mem)/total_mem))*100.0;

          cb(obj);
        });
        child.exec('cat /sys/class/net/eth0/statistics/rx_bytes; sleep 1; cat /sys/class/net/eth0/statistics/rx_bytes', function(error, stdout, stderr) {
          var lines = stdout.split("\n");
          obj.network = (parseInt(lines[1]) - parseInt(lines[0]))/1024;

          cb(obj);
        });
        child.exec('php /var/www/ts-x/templates/php/serveurs.php', function(error, stdout, stderr) {
          var lines = stdout.split("\n");
          obj.players = lines[0];

          cb(obj);
        });
      });
    } catch ( err ) {
        return res.send(err);
    }
	next();
});
/**
 * @api {get} /panel/servers GetServersInfo
 * @apiPermission admin
 * @apiName GetServersInfo
 * @apiGroup Panel
 * @apiHeader {String} auth Votre cookie de connexion.
 */
server.get('/panel/servers', function (req, res, next) {
    try {
      server.conn.query(server.getAuthAdminID, [req.headers.auth], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

        server.conn.query("SELECT `uniq_id`, `url` as `game`, `ip`, `port`, `is_on`, `current`, `maxplayers` FROM `ts-x`.`adm_serv`;", function(err, row) {
          return res.send(row);
        });
      });
    } catch ( err ) {
        return res.send(err);
    }
	next();
});

/**
 * @api {get} /panel/events GetEventsInfo
 * @apiPermission admin
 * @apiName GetEventsInfo
 * @apiGroup Panel
 * @apiHeader {String} auth Votre cookie de connexion.
 */
server.get('/panel/events', function (req, res, next) {
    try {
	      var dStart = moment().subtract(1, 'months').unix();
        server.conn.query("SELECT username, COUNT(*) as CPT FROM `ts-x`.`phpbb3_posts` P INNER JOIN `ts-x`.`phpbb3_users` U ON P.`poster_id`=U.`user_id` WHERE P.`topic_id`=20936 AND P.`post_time`>=? GROUP BY poster_id ORDER BY cpt DESC", [dStart], function(err, row) {
          return res.send(row);
        });
    } catch ( err ) {
        return res.send(err);
    }
        next();
});
/**
 * @api {get} /panel/props GetProps
 * @apiPermission admin
 * @apiName GetProps
 * @apiGroup Panel
 * @apiHeader {String} auth Votre cookie de connexion.
 */
server.get('/panel/props', function (req, res, next) {
  try {
    server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      server.conn.query("SELECT `id`, LOWER(`nom`) as nom, LOWER(`model`) as model, LOWER(`tag`) as tag, `valid` FROM `rp_shared`.`rp_props` ORDER BY `count` DESC;", function(err, row) {
        return res.send(row);
      });
    });
  } catch ( err ) {
    return res.send(err);
  }
  next();
});
/**
 * @api {get} /panel/email GetEmailInfo
 * @apiPermission admin
 * @apiName GetEmailInfo
 * @apiGroup Panel
 * @apiHeader {String} auth Votre cookie de connexion.
 */
server.get('/panel/email', function (req, res, next) {
    try {
      server.conn.query(server.getAuthAdminID, [req.headers.auth], function(err, row) {
        if( err ) return res.send(new ERR.InternalServerError(err));
        if( row[0] == null ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

        var pattern = "/[^a-zA-Z0-9_]+/g";

        var steamid = row[0].steamid;

        var email = new Array();
        email.push(row[0].username.toLowerCase().replace(pattern, ""));
        email.push("contact");
        var result = new Array();
        var tmp = 0;

        for(var i=0; i<email.length; i++) {
          var mail = email[i]

          server.conn.query("SELECT COUNT(*) as `cpt`, '"+mail+"' as `mail` FROM `ts-x`.`mail_system` WHERE LOWER(`to`)='"+mail+"@ts-x.eu';", function(err, row) {
            if( err ) console.log(err);

            var hashCode = encode(Math.random()+","+row[0].mail+","+steamid, "safe_"+steamid);
            var obj = { email: row[0].mail+"@ts-x.eu", hash: ""+hashCode+"", count: row[0].cpt };

            result.push(obj);
            tmp++;
            if( tmp == email.length ) {
              return res.send(result);
            }
          });
        }

      });
    } catch ( err ) {
        return res.send(err);
    }
	next();
});

server.post('/panel/social', function (req, res, next) {
  try {

    server.conn.query(server.getAuthSMAdmin, [req.headers.auth], function(err, row) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");
      if( SteamID != "STEAM_1:0:7490757" && SteamID != "STEAM_1:1:39278818" && SteamID != "STEAM_1:1:46128440" ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

      console.log(SteamID);

      server.conn.query("INSERT INTO `ts-x`.`site_annonces` (`titre`, `text`, `url`) VALUES (?,?,?);", [req.params['title'], req.params['txt'], req.params['url']], function(err, row) {
        if( err ) throw err;

        var res = row.insertId;
        var path = "/var/www/ts-x/cache/announcement/";

        if( req.params['url'] ) {
          var ext = req.params['url'].substr(req.params['url'].lastIndexOf('.') + 1);
          var output = path+res+'-url.'+ext;

          child.execSync('curl --silent -o '+output+' '+req.params['url']);
          req.params['url'] = output;
        }

        var obj = {title: req.params['title'], txt: req.params['txt'], url: req.params['url'] };
        fs.writeFileSync(path+res+".txt", JSON.stringify(obj));

        setTimeout( function() {
          console.log("fb");
          child.exec("casperjs /var/www/ts-x/node/api/bot/facebook.js "+res, function(error, stdout, stderr) {
            console.log(error, stdout, stderr);
            server.conn.query("UPDATE `ts-x`.`site_annonces` SET `facebook`=? WHERE `id`=?;", [stdout, res]);
          });
        }, 1);
        setTimeout( function() {
          console.log("steam");
          child.exec("casperjs /var/www/ts-x/node/api/bot/steam.js "+res, function(error, stdout, stderr) {
            console.log(error, stdout, stderr);
            server.conn.query("UPDATE `ts-x`.`site_annonces` SET `steam`=? WHERE `id`=?;", [stdout, res]);
          });
        }, 10000);
        setTimeout( function() {
          console.log("tweet");
          child.exec("casperjs /var/www/ts-x/node/api/bot/twitter.js "+res, function(error, stdout, stderr) {
            console.log(error, stdout, stderr);
            server.conn.query("UPDATE `ts-x`.`site_annonces` SET `twitter`=? WHERE `id`=?;", [stdout, res]);
          });
        }, 20000);

        return res.send("OK");
      });
    });

  }
  catch ( err ) {
      return res.send(err);
  }
  next();
});

};
