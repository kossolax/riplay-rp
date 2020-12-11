"use strict";

var fs = require('fs')
var async = require('async')
var stream = require('stream')
var es = require("event-stream")
var mysql = require('mysql2');
var chokidar = require('chokidar');
var Tail = require('tail').Tail;

var server = {};
require('./auth.js')(server);
var conn;

function chunk(array, size) {
	const chunked_arr = [];
	for (let i = 0; i < array.length; i++) {
		const last = chunked_arr[chunked_arr.length - 1];
		if (!last || last.length === size) {
			chunked_arr.push([array[i]]);
		} else {
			last.push(array[i]);
		}
	}
	return chunked_arr;
}
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

	afk: new RegExp(/L.*: \[TSX-RP\] \[AFK\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><> est maintenant AFK\./),
	noafk: new RegExp(/L.*: \[TSX-RP\] \[AFK\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><> n'est plus AFK\./),
	connect : new RegExp(/L.*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><>" entered the game/),
	disconnect: new RegExp(/L.*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><.*>" disconnected \(reason ".*"\)/),
	ip: new RegExp(/L.*: \[TSX-RP\] Loading userdata .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><> ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})/),
	kill: new RegExp(/L.*: ".*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><.*>.* killed.*<[0-9]{1,8}><(STEAM_1:[0-1]:[0-9]{1,14})><.*>\"/),

	chat: new RegExp(/L.*: ".*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><.*>.* say ".*"|L.*: \[TSX-RP\] \[CHAT-LOCAL\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><.*>: .*/),
	item: new RegExp(/L.*: \[TSX-RP\] \[ITEM\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><.*> a utilisé: .*/),
	money: new RegExp(/L.*: \[TSX-RP\] \[GIVE-MONEY\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><> a donné ([0-9]{1,8})\$ à .*<[0-9]{1,8}><(STEAM_1:[0-1]:[0-9]{1,14})><>./),
	loto: new RegExp(/L.*: \[TSX-RP\] \[ITEM-VENDRE\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><> a vendu ([0-9]{1,3}) (?:Ticket\ à\ gratter|Happy\ Meal|Ticket\ cagnotte) .*<[0-9]{1,8}><(STEAM_1:[0-1]:[0-9]{1,14})><>/),
	buy: new RegExp(/L.*: \[TSX-RP\] \[ITEM-VENDRE\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><> a vendu ([0-9]{1,3}) .*<[0-9]{1,8}><(STEAM_1:[0-1]:[0-9]{1,14})><>/),
	steal: new RegExp(/L.*: \[TSX-RP\] \[(?:VOL-18TH|VOL)\] .*<[0-9]{1,8}><STEAM_1:[0-1]:[0-9]{1,14}><> a vol.*<[0-9]{1,8}><(STEAM_1:[0-1]:[0-9]{1,14})><>.*/),
	jail: new RegExp(/L.*: \[(?:JAIL|TSX-RP)\] \[(?:JAIL|AMENDE|JUGE|CAUTION|JAIL-?.?)\].*(STEAM_1:[0-1]:[0-9]{1,14})/),

	other2: new RegExp(/(STEAM_1:[0-1]:[0-9]{1,14}).*(STEAM_1:[0-1]:[0-9]{1,14})/),
	other: new RegExp(/(STEAM_1:[0-1]:[0-9]{1,14})/)
};

var WatchEnabled = 0;
var CollectEnabled = 0;
var sql1 = "INSERT INTO `rp_bigdata` (`date`, `steamid`, `target`, `amount`, `line`, `type`, `fileId`) VALUES ?";
var sql2 = "INSERT INTO `rp_bigdata` (`date`, `steamid`, `target`, `amount`, `line`, `type`, `fileId`) VALUES (?, ?, ?, ?, ?, ?, ?)";

function parseDate(line) {
	var time = filter["date"].exec(line);
	if( time )
		return new Date(time[3], time[1]-1, time[2], time[4], time[5], time[6], 0);
}
function parseLine(line) {
	var time = filter["dateSteamID"].exec(line);
	if( time ) {
		var m = new Date(time[3], time[1]-1, time[2], time[4], time[5], time[6], 0);
		var steamID = time[7];
		var type = 'notfound';
		var target;
		var amount;

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
		if( type != 'notfound' && type != 'debug' )
			return [m, steamIDToProfile(steamID), steamIDToProfile(target), amount, line.slice(0, 250).trim(), type]
	}
}

var files = {};
conn.query("SELECT * FROM `rp_bigdata_files`", function(err, row) {
	for(const i in row) {
		files[row[i]["name"]] = row[i];
	}

	var yesterday = new Date().getTime() - (1 * 6 * 60 * 60 * 1000)
	var fileToParse = [];
	var fileToWatch = [];
	fs.readdirSync(dir).sort().map( i => {
		if( files[i] == undefined ) {
			fileToParse.push(i);
			if( (fs.statSync(dir + i).mtime).getTime() > yesterday ) {
				fileToWatch.push(i);
			}
		}
		else if( (fs.statSync(dir + i).mtime).getTime() > yesterday ) {
			fileToWatch.push(i);
		}
	});

	var loading = fileToParse.length;

	function cb() {
		loading--;

		if( loading <= 0 ) {
			fileToWatch.sort().map( i => watchFile(i) );
			var watcher = chokidar.watch(dir+"*.log", {usePolling: true, interval: 100, ignoreInitial: true});
			watcher.on('add', (ev, file) => {
				console.log("New file to watch: ", file);
				watchFile(file.replace(dir, ""));
			});
		}
	}

	fileToParse.sort().map( i => parseNewFile(i, cb) );
	if( fileToParse.length == 0 )
		cb();
});

function watchFile(file) {
	function callback(fileId) {
		console.log("Watching", file);

		var watcher = chokidar.watch(dir + file, {usePolling: true, interval: 100, ignoreInitial: true});
		watcher.on("change", path => {
			const lines = fs.readFileSync(dir+file, 'utf8').split("\n");
			const data = lines.slice(files[file]["line"]).map( i => parseLine(i) ).filter(Boolean);

			if( data.length > 0 ) {
                        	for(var i in data) { data[i].push(fileId);}

				var q = conn.query(sql1, [data]);

				files[file]["line"] = lines.length;
				conn.query("UPDATE `rp_bigdata_files` SET `stop`=?, `line`=? WHERE `id`=?", [data[data.length-1][0], files[file]["line"], fileId]);
			}
		});
	}

	if( files[file] == undefined )
		parseNewFile(file, callback);
	else
		callback(files[file]["id"]);

}
function parseNewFile(file, cb) {
	let data = fs.readFileSync(dir+file, 'utf8').split("\n");
	let length = data.length

	let first = parseDate(data[0]);
	let last =  null;
	for( let i = length -1; i>=0; i--) {
		last = parseDate(data[i]);
		if( last )
			break;
	}

	if( first === undefined ) {
		console.log(file);
	}

	data = data.map( i => parseLine(i) ).filter(Boolean);

	conn.query("INSERT INTO `rp_bigdata_files` (`name`, `start`, `stop`, `size`, `line`) VALUES (?, ?, ?, ?, ?);", [file, first, last, 0, length], function(err, row) {

		files[file] = {
			start: first,
			stop: last,
			line: length,
			id: row.insertId
		}

		if( data.length > 0 ) {
			for(var i in data) { data[i].push(row.insertId);}
			chunk(data, 4096).map( i => { conn.query(sql1, [i]) });
		}

		if( cb )
			cb(row.insertId);
	});
}
