"use strict";
exports = module.exports = function(server){
  var ERR = require('node-restify-errors');
  var fs = require('fs');
  var request = require('request');
  var priceListOld = require('../price.json');

  var SteamCommunity = require('steamcommunity');
  var SteamUser = require('steam-user');
  var SteamC = require('steamid');
  var TradeOfferManager = require('steam-tradeoffer-manager');
  var SteamTotp = require('steam-totp');
  var logOnOptions = {accountName: server.getSteamLink.username, password: server.getSteamLink.password, twoFactorCode: SteamTotp.generateAuthCode(server.getSteamLink.auth)};
  var client = new SteamUser();
  var community = new SteamCommunity();
  var manager = new TradeOfferManager({steam: client, domain: "ts-x.eu", language: "fr"});

  function getInventoryFromID(SteamID, callback) {
	function parse(appid, body) {
		try {
			body = JSON.parse(body);
		}
		catch ( e ) {
			return [];
		}
		if( !body.success )
			return [];

		var items = body.descriptions;
		var invID = new Array();
		var obj = new Array();
		Object.keys(body.assets).forEach(function (i) {
			var item = body.assets[i];
			invID[item.classid+"_"+item.instanceid] = item.assetid;
		});
		
		Object.keys(items).forEach(function (i) {
			var item = items[i];
			if( parseInt(item.tradable) == 1 ) {
					var data = {
						id: invID[item.classid+"_"+item.instanceid],
						name: item.name,
						classid: item.classid,
						instanceid: item.instanceid,
						image: item.icon_url_large ? item.icon_url_large : item.icon_url,
						hashname: item.market_hash_name,
						appid: appid,
						price: null,
					};
				data.price = getPrice(item.market_hash_name, appid);

				Object.keys(item.tags).forEach(function (j) {
					var tag = item.tags[j];
					if( tag.internal_name === "CSGO_Type_WeaponCase" || tag.internal_name == "Supply Crate" || tag.internal_name == "TF_ServerEnchantmentType"  )
						data.price = 0;
					
				});

				if( data.price >= 0.05 )
					obj.push(data);
			}

		  });
		return obj;
	}
    request("http://steamcommunity.com/inventory/" + (new SteamC(SteamID)).getSteamID64() + "/730/2?l=french&count=5000", function (error, response, body) {
      if( error ) throw new ERR.NotFoundError("SteamError");
		var root = parse(730, body);
		request("http://steamcommunity.com/inventory/" + (new SteamC(SteamID)).getSteamID64() + "/440/2?l=french&count=5000", function (error, response, body) {
			if( error ) throw new ERR.NotFoundError("SteamError");
			var child = parse(440, body);
			
			for(var i in child)
				root.push(child[i]);
			
			callback(root);
		});
      
    });
  }


  var priceListDATA = new Array();
  Object.keys(priceListOld.prices).forEach(function (j) {
	if( priceListDATA[  priceListOld.prices[j].app_id ] == undefined )
		priceListDATA[  priceListOld.prices[j].app_id ] = new Array();

    priceListDATA[  priceListOld.prices[j].app_id ][ priceListOld.prices[j].market_hash_name ] = priceListOld.prices[j].price;
  });

  if (fs.existsSync('polldata.json')) {
    manager.pollData = JSON.parse(fs.readFileSync('polldata.json'));
  }
  manager.on('pollData', function(pollData) {
  	fs.writeFile('polldata.json', JSON.stringify(pollData));
  });

  logOnOptions.twoFactorCode = SteamTotp.generateAuthCode(server.getSteamLink.auth);
  client.logOn(logOnOptions);
  client.on('loggedOn', function() {
	   console.log("Logged into Steam");
     client.setPersona(SteamUser.EPersonaState.Online);
  });
  client.on('webSession', function(sessionID, cookies) {
  	manager.setCookies(cookies);
	community.setCookies(cookies);
  });
  client.on('friendRelationship', function(sid, state) {
	if( state == 3 ) {
		setTimeout( function() {
			client.chatMessage(sid, "Salut! Tu vas recevoir d'ici quelques instant une invitation à rejoindre notre groupe steam.");
		}, 1000);
		setTimeout( function() {
			client.chatMessage(sid, "Rejoint-le puis retape /steam sur notre serveur pour obtenir tes cadeaux <3");
		}, 2000);
		setTimeout( function() {
			client.inviteToGroup(sid, "103582791456861626");
		}, 3000);
		setTimeout( function() {
			client.removeFriend(sid);
		}, 60000);
	}
  });

  manager.on('sentOfferChanged', function(offer, oldState) {
    console.log(`Offer #${offer.id} changed: ${TradeOfferManager.ETradeOfferState[oldState]} -> ${TradeOfferManager.ETradeOfferState[offer.state]}`);
    if (offer.state == TradeOfferManager.ETradeOfferState.Accepted) {
      offer.getReceivedItems(function(err, items) {
        Object.keys(items).forEach(function (i) {
          var item = items[i];
          var euro = ( getPrice(item.market_hash_name, item.appid) * 0.95);
          var money = euro * 25000;
          var SteamID = offer.partner.getSteam2RenderedID();
          var now = new Date();
          var year = now.getFullYear() - 2000;
          var month = now.getMonth() + 1;

          server.conn.query("INSERT INTO `rp_csgo`.`rp_users2` (`steamid`,`bank`) VALUES (?,?);", [SteamID, money]);
          server.conn.query("INSERT INTO `ts-x`.`site_donations` (`id`, `steamid`, `timestamp`, `month`, `year`, `code`, `amount`) VALUES (NULL, ?, ?, ?, ?, ?, ?)", [SteamID, Math.round(now.getTime()/1000), month, year, item.classid+"_"+item.instanceid, euro]);
        });
      });
    }
  });
  manager.on('newOffer', function(offer) {
	console.log(`Offer #${offer.id}: ${TradeOfferManager.ETradeOfferState[offer.state]}`);

	if( offer.isGlitched() )
		return offer.decline();

	var valid = true;
	var give = 0;

	if( offer.isOurOffer == false ) {
		Object.keys(offer.itemsToReceive).forEach(function (i) {
			var item = offer.itemsToReceive[i];

			var euro = getPrice(item.market_hash_name, item.appid);
			if( euro < 0.05 || euro === undefined || euro == null )
				valid = false;
			else
				give += euro;
		});
		if( offer.itemsToGive.length > 0 && offer.partner.getSteamID64() != 76561197975247242 ) {
			valid = false;
			console.log(offer.partner.getSteamID64() + " hacking attempt.");
		}
	}

	if( valid ) {
		offer.accept(function(err, status) {
			if( status == "pending" ) {
				community.acceptConfirmationForObject(server.getSteamLink.identity, offer.id, function(err) {
					if (err)
						console.log(err);
					else
						console.log("Offer confirmed");
				});
			}
			else {
				console.log("Offer confirmed");

				var money = give * 0.95 * 25000;
				var SteamID = offer.partner.getSteam2RenderedID();
				var now = new Date();
				var year = now.getFullYear() - 2000;
				var month = now.getMonth() + 1;

				server.conn.query("INSERT INTO `rp_csgo`.`rp_users2` (`steamid`,`bank`) VALUES (?,?);", [SteamID, money]);
				server.conn.query("INSERT INTO `ts-x`.`site_donations` (`id`, `steamid`, `timestamp`, `month`, `year`, `code`, `amount`) VALUES (NULL, ?, ?, ?, ?, ?, ?)", [SteamID, Math.round(now.getTime()/1000), month, year, "steam-self", give]);

			}
		});
	}
	else {
		offer.decline();
	}
  });

  function getPrice(name, appid) {
/*
	if( appid === undefined && priceListDATA[730][name] != undefined  )
		appid = 730;
	if( appid === undefined && priceListDATA[440][name] != undefined  )
		appid = 440;
*/
	if( priceListDATA[appid] === undefined || priceListDATA[appid][name] === 0 )
		return 0;
    return parseFloat(priceListDATA[appid][name]);
  }

  /**
   * @api {get} /trade/inventory/:steam
   * @apiName GetSteamInvetory
   * @apiParam {Intger} job
   * @apiGroup Steam
   */
server.put('/steam/trade', function (req, res, next) {
  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid.replace("STEAM_0", "STEAM_1");

    var partner = req.params['partner'].trim();
    var tokken  = req.params['tokken'].trim();

    server.conn.query("UPDATE `ts-x`.`phpbb3_users` SET `partner`=?, `tokken`=? WHERE `steamid`=?", [partner, tokken, SteamID.replace("STEAM_1", "STEAM_0")], function(err, row) {
      if( err ) return res.send(new ERR.InternalServerError(err));
      return res.send("OK");
    });
  });
});
/**
 * @api {get} /trade/inventory/:steam
 * @apiName GetSteamInvetory
 * @apiParam {Intger} job
 * @apiGroup Steam
 */
server.post('/steam/trade', function (req, res, next) {
  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid;

    try {
      getInventoryFromID(SteamID, function(obj) {
        Object.keys(obj).forEach(function (i) {
          var item = obj[i];

          if( item.id == parseInt(req.params['itemid']) ) {

            var euro = getPrice(item.hashname, item.appid);
            var money = (euro * 0.95) * 25000;
            if( euro < 0.05 ) return res.send(new ERR.NotFoundError("InventoryError"));

		console.log("about to send offer of " + money);

            server.conn.query("SELECT `partner`, `tokken` FROM `ts-x`.`phpbb3_users` WHERE `steamid`=?", [SteamID], function(err, row) {
              if( err ) return res.send(new ERR.InternalServerError(err));
              var offer = manager.createOffer(SteamID);
              offer.setMessage("Votre item vaut: "+Math.round(money)+" $RP, selon les prix actuels sur le marché.");
              offer.setToken(row[0].tokken);
              offer.addTheirItem({appid: item.appid, contextid: 2, assetid: item.id});
              offer.send(function(err, status) {
                if( err && err.eresult == 15 ) return res.send({id: -1});
                else if( err && err.eresult == 50 ) return res.send({id: -2});
                else if( err ) return res.send(new ERR.InternalServerError(err));
                res.send({id: offer.id});
                return next();
              });

            });

          }
        });
      });
    }
    catch( e ) {
      console.log("bug while sending.."+e);
    }
  });
});

/**
 * @api {get} /steam/twofactor/:id
 * @apiName GetSteamTwoFactor
 * @apiGroup Steam
 */
server.get('/steam/twofactor/:id', function (req, res, next) {
  return res.send(SteamTotp.generateAuthCode(req.params['id']));
});

/**
 * @api {get} /steam/trade
 * @apiName GetSteamInvetory
 * @apiGroup Steam
 */
server.get('/steam/trade', function (req, res, next) {
  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid;

    var cache = server.cache.get( req._url.pathname+"/"+SteamID );
    if( cache != undefined ) return res.send(cache);

    manager.getOffers(1, function(err, sent, received) {

      var obj = new Array();
      if( sent != null ) {
        Object.keys(sent).forEach(function (i) {
          if( sent[i].partner.getSteamID64() == (new SteamC(SteamID)).getSteamID64() ) {
            var item = sent[i].itemsToReceive[0];
            var data = {
              id: sent[i].id,
              name: item.name,
              image: item.icon_url_large ? item.icon_url_large : item.icon_url,
              price: getPrice(item.market_hash_name, item.appid),
              escrow: sent[i].escrowEnds
            };
            obj.push(data);

          }
        });
      }
      server.cache.set( req._url.pathname+"/"+SteamID, obj, 5);
      res.send(obj);
      return next();
    });
    next();
  });
});
server.get('/steam/invite/:id', function (req, res, next) {
	client.addFriend(req.params['id']);
	res.send("done");
	return next();
});
server.get('/steam/group/:id', function (req, res, next) {
	var SteamID = req.params['id'];
	var cache = server.cache.get( req._url.pathname+"/"+SteamID );
	if( cache != undefined ) return res.send(""+cache.res);
	community.getGroupMembers("103582791456861626", function(err, members) {
		var f = 0;
		for(var i = 0; i<members.length; i++) {
			if( members[i] == SteamID ) {
				f = 1;
				break;
			}
		}

		server.cache.set( req._url.pathname+"/"+SteamID, {res: f}, 10);
		res.send(""+f);
		return next();
	});
});

  /**
   * @api {get} /steam/inventory
   * @apiName GetSteamInvetory
   * @apiGroup Steam
   */
server.get('/steam/inventory', function (req, res, next) {
  server.conn.query(server.getAuthSteamID, [req.headers.auth], function(err, row) {
    if( err ) return res.send(new ERR.InternalServerError(err));
    if( row.length == 0 ) return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
    var SteamID = row[0].steamid;

    var cache = server.cache.get( req._url.pathname+"/"+SteamID );
    if( cache != undefined ) return res.send(cache);

    try {
      getInventoryFromID(SteamID, function(obj) {
        server.cache.set( req._url.pathname+"/"+SteamID, obj, 5);
        res.send(obj);
      });
    }
    catch( e ) {
      console.log(e);
      return res.send(e);
    }
  });
});

  /**
   * @api {get} /steam/inventory/:id
   * @apiName GetSteamInvetory
   * @apiGroup Steam
   */
server.get('/steam/inventory/:id', function (req, res, next) {
  var SteamID = req.params['id']
  var cache = server.cache.get( req._url.pathname+"/"+SteamID );
  if( cache != undefined ) return res.send(cache);

  try {
    getInventoryFromID(SteamID, function(obj) {
      server.cache.set( req._url.pathname+"/"+SteamID, obj, 5);
      res.send(obj);
    });
  }
  catch( e ) {
    console.log("bug");
    return res.send(e);
  }
  next();
});


};
