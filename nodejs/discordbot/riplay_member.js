var mysql = require('mysql');

var db = mysql.createConnection({
  host: "cpu-linux.riplay.fr",
  user: "discord",
  password: "1Wvq83umcVKBmQUx",
  database: "discord"
});

db.connect((err) => {
    if (err) {
        throw err;
    }
    console.log('Connected to database');
});
global.db = db;

class RiplayMember {
  constructor(discord) {
    this.discord = discord.toString();
  }

  register() {
    var temp = this;

    let promise = new Promise(function(resolve, reject) {

      var steamid = temp.getSteamID();

      steamid.then(function(authid) {
        if(authid != null) {
          //console.log("this discord already exist");
          resolve(null);
        } else {
          var result = temp.getToken();
          var tokens = null;

          result.then(function(gettokens) {
            if(gettokens == null) {
              //console.log("Tokens is null, create tokens");
              var tokens = temp.createToken();
              resolve(tokens);
            } else {
              //console.log("Token is not null");
              resolve(gettokens);
            }
          }).catch(function(err) {
            resolve(null);
          });
        }
      }).catch(function(err) {
        resolve(null);
      });
    });

    return promise;
  }

  getSteamID() {
    var temp = this;

    let promise = new Promise(function(resolve, reject) {
      var sql = "SELECT authid FROM discord_members WHERE discord = ?";
      var query = db.query(sql, [temp.discord], function (err, result, fields) {

      if (err) {
        reject(err);
      }
      else {
          if(result.length == 0) {
              //console.log("no steamid in db");
              resolve(null);
            } else {
              //console.log(result[0].authid);
              resolve(result[0].authid);
          }
        }
      });
    })

    return promise;
  }

  revoke() {
    var temp = this;

    let promise = new Promise(function(resolve, reject) {
      var sql = "DELETE FROM discord_members WHERE discord = ?";
      var query = db.query(sql, [temp.discord], function (err, result) {

      if (err) {
        reject(err);
      }
      else {
          if(result.affectedRows == 0) {
              //console.log("no steamid in db");
              resolve(false);
            } else {
              //console.log(result[0].authid);
              resolve(true);
          }
        }
      });
    });

    return promise;
  }

  createToken() {
    var tempDiscord = this.discord;
    var timestamp = Timestamp();
    var tokens = randomPassword(16);
    var validity = timestamp + 7200;

	  var sql = "INSERT INTO discord_members_tokens (discord, tokens, validity) VALUES ?";
	  var values = [[tempDiscord, tokens, validity]];
    var query = db.query(sql, [values]);

    query.on('error', function(err) {
        throw err;
    });

    //console.log("tokens created:");
    return tokens;
  }

  getToken() {
    //console.log("call getTokens");
    var tempDiscord = this.discord;

    let promise = new Promise(function(resolve, reject) {
      //console.log("promise getTokens");

      var timestamp = Timestamp();

      var sql = "SELECT tokens, validity FROM discord_members_tokens WHERE discord = ? AND validity >= ? LIMIT 1";
      var query = db.query(sql, [tempDiscord, timestamp], function (err, result, fields) {

      if (err) {
        reject(err);
      }
      else {
          if(result.length == 0) {
            //console.log("No tokens on the db");
            resolve(null);
          } else {
            if(result[0].validity > timestamp) {
                //console.log("Tokens" + result[0].tokens + " is already valid");
                resolve(result[0].tokens);
            } else {
                //console.log("Tokens" + result[0].tokens + " is not valid anymore");
                resolve(null);
            }
          }
        }
      });
    })

    return promise;
  }

  getRegisterUrl() {
    var url = "http://riplay.fr/discord/";
    return url;
  }
} 

// ------------------------------------------------------------------------------------------------------------------------

function randomPassword(length) {
    var chars = "!^@#$%-_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOP1234567890";
    var pass = "";
    for (var x = 0; x < length; x++) {
        var i = Math.floor(Math.random() * chars.length);
        pass += chars.charAt(i);
    }
    return pass;
}

function Timestamp() {
  return Math.floor(Date.now() / 1000);
}

module.exports = RiplayMember;