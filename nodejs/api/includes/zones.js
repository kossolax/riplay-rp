"use strict";
exports = module.exports = function(server){
  var ERR = require('node-restify-errors');
  var moment = require('moment');
/**
 * @api {get} /zone/:x/:y:/:z GetZoneByLocation
 * @apiName GetZoneByLocation
 * @apiGroup Zone
 * @apiParam {float} x
 * @apiParam {float} y
 * @apiParam {float} z
 */
server.get('/zone/:x/:y/:z', function (req, res, next) {
  if( req.params['id'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  server.conn.query("SELECT `id`, `zone_name` FROM `rp_location_zones` WHERE `min_x` < ? AND `max_x` > ? AND `min_y` < ? AND `max_y` > ? AND `min_z` < ? AND `max_z` > ? AND `id`>0 ORDER BY `id` ASC LIMIT 1;", [req.params['x'], req.params['x'], req.params['y'], req.params['y'], req.params['z'], req.params['z']], function(err, rows) {
    if( rows.length == 0 ) return res.send({id: 0, zone_name: "Extérieur"});

    return res.send(rows[0]);
	});
	next();
});

/**
 * @api {get} /zone/:id GetZoneById
 * @apiName GetZoneById
 * @apiGroup Zone
 * @apiParam {Integer} id Un identifiant unique correspondant à la zone.
 */
server.get('/zone/:id', function (req, res, next) {
  if( req.params['id'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  server.conn.query("SELECT * FROM `rp_location_zones` WHERE `id`=?", [req.params['id']], function(err, rows) {
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("ZoneNotFound"));

    var obj = new Object();
    obj.nom = rows[0].zone_name;
    obj.type = rows[0].zone_type;
    obj.min = new Array(rows[0].min_x, rows[0].min_y, rows[0].min_z);
    obj.max = new Array(rows[0].max_x, rows[0].max_y, rows[0].max_z);

    return res.send(obj);
	});
	next();
});
server.get('/zones', function (req, res, next) {
  if( req.params['id'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  var expire = moment({hour: 6}).toDate();
  if( req.headers['if-none-match'] == expire.getTime() ) { return res.send(304); }
  res.header('ETag', expire.getTime());

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) {  return res.send(cache); }

  server.conn.query("SELECT *, SUBSTRING(`job_name`, LOCATE(' - ', `job_name`)+3) as `job_name`, SUBSTRING(`zone_name`, LOCATE(': ', `zone_name`)+1) as `zone_name` FROM `rp_location_zones` Z LEFT JOIN `rp_jobs` J ON J.`job_id`=Z.`zone_type`  GROUP BY `min_x`, `min_y`, `max_x`, `max_y`", [req.params['id']], function(err, rows) {
    if( rows.length == 0 ) return res.send(new ERR.NotFoundError("ZoneNotFound"));

    var array = new Array();

    for(var i=0; i<rows.length; i++) {
      var obj = new Object();
      obj.type = rows[i].zone_type;
      obj.name = rows[i].zone_name.trim();
      if( rows[i].job_name == "ns emploi" )
        rows[i].job_name = "";
      obj.owner = rows[i].job_name.trim();
      obj.private = rows[i].private;

      obj.min = new Array(rows[i].min_x, rows[i].min_y/*, rows[i].min_z*/);
      obj.max = new Array(rows[i].max_x, rows[i].max_y/*, rows[i].max_z*/);
      array.push(obj);
    }

    server.cache.set( req._url.pathname, array, 3600);
    return res.send(array);
	});
	next();
});

};
