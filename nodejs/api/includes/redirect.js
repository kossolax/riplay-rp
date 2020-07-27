+"use strict";
exports = module.exports = function(server) {
  var ERR = require('node-restify-errors');

/**
 * @api {post} /redirect/:steamid redirect
 * @apiName redirect
 * @apiParam {Steamid} steamid
 * @apiParam {URL} url
 * @apiGroup Live
 */
server.post('/redirect/:steamid', function(req, res, next) {
	var steamid = req.params["steamid"];
	var url = req.params["url"];
	server.conn.query("INSERT INTO `rp_shared`.`urls` (`steamid`, `url`) VALUES (?,?) ON DUPLICATE KEY UPDATE `url`=?;", [steamid, url, url], function(err, row) {
		return res.send("ok");
	});
	next();
});
/**
 * @api {get} /redirect/:steamid redirect
 * @apiName redirect
 * @apiParam {Steamid} steamid
 * @apiGroup Live
 */
server.get('/redirect/:steamid', function(req, res, next) {
        var steamid = req.params["steamid"];
        var url = req.params["url"];
        server.conn.query("SELECT `url` FROM `rp_shared`.`urls` WHERE `steamid`=?;", [steamid], function(err, row) {
		var str = "<script type='text/javascript'>";
		str += "window.open('"+ row[0].url +"', '_blank', 'toolbar=yes, fullscreen=yes, scrollbars=yes');";
		str += "</script>";

		res.writeHead(200, {
			'Content-Length': Buffer.byteLength(str),
			'Content-Type': 'text/html'
		});
		res.write(str);
		return res.end();
        });
        next();
});

};
