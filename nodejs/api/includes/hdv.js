"use strict";
exports = module.exports = function(server){
  var ERR = require('node-restify-errors');


  /**
   * @api {get} /hdv/sales/:job
   * @apiName GetHdvSales
   * @apiParam {Intger} job
   * @apiGroup HDV
   */
server.get('/hdv/sales/:job', function (req, res, next) {

  if( isNaN(parseInt(req.params['job'])) )
    return res.send("[]");

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) { return res.send(cache); }

  var sql = "SELECT `itemID`, `nom`, `amount`, `price`, I.`fees` FROM `rp_trade` T";
  sql += " INNER JOIN `rp_items` I ON T.`itemID`=I.`id`";
  sql +=  " WHERE `boughtBy` IS NULL";
  if( parseInt(req.params['job']) != 0 )
    sql += " AND I.`job_id`=?";

  sql += " ORDER BY (`amount`*`price`) ASC;";

  console.log(sql);

  server.conn.query(sql, [parseInt(req.params['job'])], function(err, rows) {
    if( err ) return res.send(new ERR.InternalServerError(err));

    server.cache.set( req._url.pathname, rows, 30);
    console.log(rows);
    return res.send( rows );
  });

  next();
});
};
