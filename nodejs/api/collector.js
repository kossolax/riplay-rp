"use strict";

var fs = require('fs')
var async = require('async')
var stream = require('stream')
var es = require("event-stream")
var mysql = require('mysql2');
var hound = require('hound');

var server = {};
require('./auth.js')(server);
var conn;

function steamIDToProfile(steamID) {
	if( steamID == undefined ) return null;

	var parts = steamID.split(":");
	if( parts.length <= 1 ) return steamID;
	var iServer = Number(parts[1]);
	var iAuthID = Number(parts[2]);
	var converted = "76561197960265728"
	var lastIndex = converted.length - 1

	var toAdd = iAuthID * 2 + iServer;
	var toAddString = new String(toAdd)
	var addLastIndex = toAddString.length - 1;

	for(var i=0;i<=addLastIndex;i++) {
		var num = Number(toAddString.charAt(addLastIndex - i));
		var j=lastIndex - i;

		do {
			var num2 = Number(converted.charAt(j));
			var sum = num + num2;

			converted = converted.substr(0,j) + (sum % 10).toString() + converted.substr(j+1);

			num = Math.floor(sum / 10);
			j--;
		} while(num);
	}
	return converted;
}

function handleDisconnect() {
	conn = mysql.createConnection(server.db_config);
	conn.connect(function(err) {
		if( err ) {
			setTimeout(handleDisconnect, 2000);
		}
		conn.query("SET NAMES 'utf8mb4'");
	});
	conn.on('error', function(err) {
		handleDisconnect();
	});
}
handleDisconnect();

var dir = "/home/serveurs/csgo/roleplay_prod/csgo/logs/";

var files = fs.readdirSync(dir).sort();
var filter = {
	date: new RegExp(/^L ([0-9]{2})\/([0-9]{2})\/([0-9]{4}) - ([0-9]{2}):([0-9]{2}):([0-9]{2}):/),
	dateSteamID: new RegExp(/^L ([0-9]{2})\/([0-9]{2})\/([0-9]{4}) - ([0-9]{2}):([0-9]{2}):([0-9]{2}):.+?<(STEAM_1:[0-1]:[0-9]{1,14})>/),

	debug: new RegExp(/L.*: \[DEBUG\]/),

	afk: new RegExp(/L.*: \[RIPLAY-RP\] \[AFK\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><> est maintenant AFK\./),
	noafk: new RegExp(/L.*: \[RIPLAY-RP\] \[AFK\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><> n'est plus AFK\./),
	connect : new RegExp(/L.*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><>" entered the game/),
	disconnect: new RegExp(/L.*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><.*>" disconnected \(reason ".*"\)/),
	ip: new RegExp(/L.*: \[RIPLAY-RP\] Loading userdata .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><> ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})/),
	kill: new RegExp(/L.*: ".*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><.*>.* killed.*<[0-9]{1,8}><(STEAM_1:[0-1]:[0-9]{1,14})><.*>\"/),

	chat: new RegExp(/L.*: ".*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><.*>.* say ".*"|L.*: \[RIPLAY-RP\] \[CHAT-LOCAL\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><.*>: .*/),
	item: new RegExp(/L.*: \[RIPLAY-RP\] \[ITEM\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><.*> a utilisé: .*/),
	money: new RegExp(/L.*: \[RIPLAY-RP\] \[GIVE-MONEY\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><> a donné ([0-9]{1,8})\$ à .*<[0-9]{1,8}><(STEAM_1:[0-1]:[0-9]{1,14})><>./),
	loto: new RegExp(/L.*: \[RIPLAY-RP\] \[ITEM-VENDRE\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><> a vendu ([0-9]{1,3}) (?:Ticket\ à\ gratter|Happy\ Meal|Ticket\ cagnotte) .*<[0-9]{1,8}><(STEAM_1:[0-1]:[0-9]{1,14})><>/),
	buy: new RegExp(/L.*: \[RIPLAY-RP\] \[ITEM-VENDRE\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><> a vendu ([0-9]{1,3}) .*<[0-9]{1,8}><(STEAM_1:[0-1]:[0-9]{1,14})><>/),
	steal: new RegExp(/L.*: \[RIPLAY-RP\] \[(?:VOL-18TH|VOL)\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><> a vol.*<[0-9]{1,8}><(STEAM_1:[0-1]:[0-9]{1,14})><>.*/),
	jail: new RegExp(/L.*: \[(?:JAIL|RIPLAY-RP)\] \[(?:JAIL|AMENDE|JUGE|CAUTION|JAIL-?.?)\].*(STEAM_1:[0-1]:[0-9]{1,14})/),

	other2: new RegExp(/(STEAM_1:[0-1]:[0-9]{1,14}).*(STEAM_1:[0-1]:[0-9]{1,14})/),
	other: new RegExp(/(STEAM_1:[0-1]:[0-9]{1,14})/)
};

var WatchEnabled = 0;
var CollectEnabled = 0;
var sql1 = "INSERT INTO `rp_bigdata` (`date`, `steamid`, `target`, `amount`, `line`, `type`, `fileId`) VALUES ?";
var sql2 = "INSERT INTO `rp_bigdata` (`date`, `steamid`, `target`, `amount`, `line`, `type`, `fileId`) VALUES (?, ?, ?, ?, ?, ?, ?)";


collect(files);
function collect(files) {
  if( CollectEnabled == 1 ) return;
  CollectEnabled = 1;
  conn.query("SELECT * FROM `rp_bigdata_files`", function(err, row) {

    var fData = {};
    for(var i in row) { fData[row[i].name] = row[i]; }

    async.each(files, function(file, callback) {
      var fi  = fs.statSync(dir+file);

      if( fi["size"] < 8400 ) return callback();
      if( fData[file] && (fi['mtime'] <= fData[file].stop || fi['size'] <= fData[file]['size']) ) { /*console.log("skip");*/ return callback(); }

      var data = new Array();
      var type, time, steamID, m, first, last = [], target, amount, i = 0;

      var s = fs.createReadStream(dir+file).pipe(es.split()) .pipe(es.mapSync(function(line) {
        if( line != "" ) {
          i++;
          if( !fData[file] || (fData[file] && i>fData[file].line) ) {
            if( first === undefined )
              first = line;
            last[0] = last[1];
            last[1] = line;
            time = filter["dateSteamID"].exec(line);
            if( time ) {
              //console.log("new     : " +line);
              m = new Date(time[3], time[1]-1, time[2], time[4], time[5], time[6], 0);
              steamID = time[7];
              type = 'notfound';
              for(var j=2; j<Object.keys(filter).length; j++) {

                time = filter[Object.keys(filter)[j]].exec(line);

                if( time ) {

                  type = Object.keys(filter)[j];
                  if( type == 'other2' )
                    type = 'other'

                  target = (time[2] ? time[2] : time[1]);
                  amount = parseInt(time[2] ? time[1] : null);
		  if( isNaN(amount) )
			amount = null;
                  break;
                }
              }
              if( type != 'notfound' ) {
                data.push([m, steamIDToProfile(steamID), steamIDToProfile(target), amount, line, type]);
                //console.log("data found" + [m, steamID, target, amount, line, type] );
              }
            }
          }
          else {
            if( i+10 > fData[file].line ) {
              //console.log("skipped : " + (fData[file]) + "   " + (i>=fData[file].line) + "   "+ line);
            }
          }
        }
      })
      .on('end', function() {
        if( data.length > 0 ) {
            try {
              var time = filter["date"].exec(first);
              first = new Date(time[3], time[1]-1, time[2], time[4], time[5], time[6], 0);
              time = filter["date"].exec( (last[1].length > "L 11/21/2015 - 23:35:53:".length ?last[1]:last[0]) );
              last = new Date(time[3], time[1]-1, time[2], time[4], time[5], time[6], 0);

              if( fData[file] ) {
                conn.query("UPDATE `rp_bigdata_files` SET `stop`=?, `size`=?, `line`=? WHERE `id`=?;", [last, fi['size'], i, fData[file].id], function(err, row) {
                  for(var i in data) {
			data[i].push(fData[file].id);
		  }
                  conn.query(sql1, [data], function(err, row) {
			console.log(err);
			return callback();
	 	 });
                });
              }
              else {
                conn.query("INSERT INTO `rp_bigdata_files` (`name`, `start`, `stop`, `size`, `line`) VALUES (?, ?, ?, ?, ?);", [file, first, last, fi['size'], i], function(err, row) {
                  for(var i in data) { data[i].push(row.insertId);  }
                  conn.query(sql1, [data], function(err, row) { return callback(); });
                });
              }
            } catch ( err ) {
              console.log("something happen while parsing date:");
              console.log(err);
              return callback();
            }
        }
        else
          return callback();
      }));
    }, function(err) {
//      console.log("parsing ended");
      if( files.length > 1 )
        watchUpdate();
      CollectEnabled = 0;
    });
  });
}

function watchUpdate() {
//  return;
  if( WatchEnabled == 1 ) return;
  WatchEnabled = 1;
  var watcher = hound.watch(dir);

  watcher.on('create', cb);
  watcher.on('change', cb);
  watcher.on('delete', cb);
  function cb(file, stat) {
    file = file.replace(dir+"/", "");
    collect([file]);
  }
}

