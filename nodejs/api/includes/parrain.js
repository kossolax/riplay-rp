"use strict";
exports = module.exports = function (server) {
    var request = require('request');
    var ERR = require('node-restify-errors');
    var moment = require('moment');

    /**
   * @api {get} /parrain GetFilleuls
   * @apiName GetFilleuls
   * @apiGroup Parrain
   * @apiHeader {String} auth Votre cookie de connexion.
   */

    server.get('/parrain', function (req, res, next) {
        server.conn.query(server.getAuthSteamID, [req.headers.auth], function (err, row) {
            if (row.length == 0) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
            var uid = row[0].steamid;

            var sql = "SELECT P.steamid, P.timestamp, ID.played, P.approuved, U.name ";
            sql += "FROM rp_parrain P ";
            sql += "INNER JOIN rp_idcard ID ON ID.steamid=P.steamid ";
            sql += "INNER JOIN rp_users U ON U.steamid=P.steamid ";
            sql += "WHERE P.parent = ? "
            sql += "ORDER BY ID.played DESC"

            server.conn.query(sql, [uid], function (err, rows) {
                return res.send(rows);
            });
        });
        next();
    });


    var parainnageCash = 30000;
    var parainnageExp = 18000;

    /**
   * @api {post} /parrain/:steamidfilleul/validate ValideParainnage
   * @apiName ValideParainnage
   * @apiGroup Parrain
   * @apiHeader {String} auth Votre cookie de connexion.
   */
    server.post('/parrain/:steamidfilleul/validate', function (req, res, next) {
        server.conn.query(server.getAuthSteamID, [req.headers.auth], function (err, row) {
            if (row.length == 0) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
            var uid = row[0].steamid;

            var sql = "UPDATE rp_parrain P "
            sql += "INNER JOIN rp_idcard ID ON ID.steamid=P.steamid ";
            sql += "SET P.approuved = 1 ";
            sql += "WHERE  P.approuved = 0 AND ID.played>72000 AND P.steamid = ? and P.parent = ? ";
            server.conn.query(sql, [req.params['steamidfilleul'], uid], function (err, result) {
                if (result.affectedRows != 1) {
                    return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
                }
                // On a réussi a set approuvé à true, pour le parainnage en question et il est valide, on donne l'argent & xp
                server.conn.query(
                    "INSERT INTO `rp_users2` (`id`, `steamid`, `bank`, `xp`, `pseudo`, `steamid2`) VALUES (NULL, ?, ?, ?, ?, ?);",
                    [uid, parainnageCash, parainnageExp, "Parrainage", "SERVER"], function (err, row) {

                        if (err) return res.send(new ERR.InternalServerError("Error rp_users2 " + err));

                        server.cache.del("/user/" + uid);

                        return res.send("OK");
                    });
                server.conn.query(
                    "INSERT INTO `rp_users2` (`id`, `steamid`, `bank`, `xp`, `pseudo`, `steamid2`) VALUES (NULL, ?, ?, ?, ?, ?);",
                    [req.params['steamidfilleul'], filleulCash, filleulExp, "votre parrain", "SERVER"], function (err, row) {
                        console.error("Error rp_users2 " + err);
                    });
            });
        });
        next();
    });
}
