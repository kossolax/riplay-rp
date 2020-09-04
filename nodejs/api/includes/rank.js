"use strict";
exports = module.exports = function(server){
  var ERR = require('node-restify-errors');
  var moment = require('moment');

  /**
   * @api {get} /best/freekill GetTxFreekill
   * @apiName GetTxFreekill
   * @apiGroup Rank
   */
server.get('/best/freekill', function (req, res, next) {

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) { return res.send(cache); }

  var sql = "SELECT * FROM `rp_csgo`.`rp_bigdata_tx` ORDER BY `rp_bigdata_tx`.`time` ASC";

  server.conn.query(sql, function(err, rows) {

    var tmp = [];
    for (var i = 0, len = rows.length; i < len; i++) {
      tmp.push( Array( rows[i].time.getTime(), Math.round(rows[i].kill/rows[i].player * 1000000.0)/100.0 ) );
    }

    var obj2 = new Object();
    obj2.title = 'Taux de freekill';
    obj2.data = [
      { data: tmp, tooltip: { valueSuffix: 'tx' }, yAxis: 0},
    ];
    obj2.axis = [
      {title: { text: 'Taux de kill'}, min: 0, lineWidth: 0},
    ];
    server.cache.set( req._url.pathname, obj2, 300);
    return res.send( obj2 );
  });

  next();
});

  /**
   * @api {get} /best/job GetBestJob
   * @apiName GetBestJob
   * @apiGroup Rank
   */
server.get('/best/job', function (req, res, next) {

  var cache = server.cache.get( req._url.pathname);
  if( cache != undefined ) { return res.send(cache); }

  var sql = "SELECT J.`job_id` as id, SUBSTRING(`job_name`, LOCATE(' - ', `job_name`)+3) as name, ROUND(`total`) as y FROM `rp_csgo`.`rp_jobs` J";
	sql += "   INNER JOIN ( ";
	sql += "     SELECT `job_id`, SUM(`prix`*`used`*`taxes`) total FROM `rp_csgo`.`rp_items` I ";
	sql += "       INNER JOIN ( ";
  sql += "        SELECT `item_id`, SUM(`amount`) used FROM `rp_csgo`.`rp_sell` WHERE `item_type`='0' AND `item_id`!=0 AND `timestamp`>UNIX_TIMESTAMP()-(7*24*60*60) GROUP BY `item_id`";
	sql += "       ) S ON S.`item_id`=I.`id`";
	sql += "       WHERE `job_id`!=0 GROUP BY `job_id`";
	sql += "   ) S ON S.`job_id`=J.`job_id`";
  sql += "   ORDER BY `total` DESC";

  server.conn.query(sql, function(err, rows) {

    var obj2 = new Object();
    obj2.title = 'Meilleurs ventes';
    obj2.data = [{ data: rows }];
    obj2.axis = [{lineWidth: 0}];

    server.cache.set( req._url.pathname, obj2, 300);
    return res.send( obj2 );
  });

  next();
});

/**
 * @api {get} /best/job/:id GetBestJobItem
 * @apiName GetBestItem
 * @apiParam {Intger} id
 * @apiGroup Rank
 */
server.get('/best/job/:id', function (req, res, next) {

var cache = server.cache.get( req._url.pathname);
if( cache != undefined ) { return res.send(cache); }

var sql = "SELECT I.`id` as id, `nom` as name, ROUND(`total`) as y FROM `rp_items` I";
sql += "   INNER JOIN ( ";
sql += "     SELECT `item_id`, SUM(`prix`*`used`*`taxes`) total FROM `rp_items` I ";
sql += "       INNER JOIN ( ";
sql += "        SELECT `item_id`, SUM(`amount`) used FROM `rp_csgo`.`rp_sell` WHERE `item_type`='0' AND `item_id`!=0 AND `timestamp`>UNIX_TIMESTAMP()-(7*24*60*60) GROUP BY `item_id`";
sql += "       ) S ON S.`item_id`=I.`id`";
sql += "       WHERE `job_id`=? GROUP BY `item_id`";
sql += "   ) S ON S.`item_id`=I.`id`";
sql += "   ORDER BY `total` DESC";

server.conn.query(sql, [req.params['id']], function(err, rows) {
  console.log(err);
  var obj2 = new Object();
  obj2.title = 'Meilleurs ventes';
  obj2.data = [{ data: rows }];
  obj2.axis = [{lineWidth: 0}];

  server.cache.set( req._url.pathname, obj2, 300);
  return res.send( obj2 );
});

next();
});

/**
 * @api {get} /rank/:type GetRankByType
 * @apiName GetRankByType
 * @apiGroup Rank
 * @apiParam {String=zombie,pvp,sell,buy,money,age,parrain,vital,success,freekill,general,artisan} type Un identifiant correspondant au type
 */
server.get('/rank/:type', function (req, res, next) {
  if( req.params['type'] == 0 )
    return res.send(new ERR.BadRequestError("InvalidParam"));

  if(req.params['type'] == 'donate') {
    var cache = server.cache.get( req._url.pathname);
    if( cache != undefined ) { return res.send(cache); }

    var sql = "SELECT `steamid`, `name`, `donateur` FROM `rp_csgo`.`rp_users` WHERE `donateur` > 0 ORDER BY `donateur` ASC LIMIT 10;";
    server.conn.query(sql, [], function(err, rows) {
      var obj = {rank: [], needed: 0};
      obj.rank = rows;

      /* get the requier amount in order to pass top10 */
      sql = "SELECT SUM(`amount`) AS `cpt`, D.`steamid` FROM `rp_shared`.`site_donations` D WHERE `month`=MONTH(CURRENT_DATE()) AND `year`=YEAR(CURRENT_DATE())-2000 AND D.`steamid`<>'' GROUP BY `steamid` ORDER BY `cpt` DESC, `steamid` DESC LIMIT 10;";
      server.conn.query(sql, [], function(err, rows) {
        if(rows.length == 10) {
          obj.needed = parseFloat(((rows[rows.length-1].cpt + 0.35) / (1 - 0.029)).toFixed(2)) + 0.01;
        } else {
          obj.needed = null;
        }

        server.cache.set( req._url.pathname, obj, 300);
        res.send(obj);
      });
    });


  } else {
    var expire = moment({hour: 6});

    if( req.headers['if-none-match'] == expire.unix() ) { return res.send(304); }
    res.header('ETag', expire.unix());
    res.header('Last-Modified', expire.toDate());
    res.header('Expires', expire.add(1, 'day').toDate());
    res.header('Cache-Control', 'Public');


    var cache = server.cache.get( req._url.pathname);
    if( cache != undefined ) { return res.send(cache); }

    var sql = "SELECT R.`steamid`, `name`, `rank`, `old_rank`, R.`point`, `old_point` FROM `rp_csgo`.`rp_rank` R INNER JOIN `rp_csgo`.`rp_users` U ON R.`steamid`=U.`steamid` WHERE type=? AND R.`point`>'0' ORDER BY `rank` ASC;";
    server.conn.query(sql, [req.params['type']], function(err, rows) {
      if( rows.length == 0 ) return res.send(new ERR.NotFoundError("InvalidParam"));

      var obj = new Array();
      for(var i=0; i<rows.length; i++) {
        var row = new Array(); var j=0;
        row[j++] = rows[i].steamid;
        row[j++] = rows[i].name;
        row[j++] = rows[i].rank;
        row[j++] = rows[i].old_rank;
        row[j++] = rows[i].point;
        row[j++] = rows[i].old_point;
        obj.push(row);
      }
      server.cache.set( req._url.pathname, obj, 3600);
      res.send(obj);
  	});
  }
	next();
});
};
