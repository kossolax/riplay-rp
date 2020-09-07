const RiplayMember = require('./riplay_member.js');
const Gamedig = require('gamedig');
const http = require('http');
const url = require('url');
const request = require('request');

const Discord = require('discord.js');
const client = new Discord.Client();

var COMMAND_REGISTER = '/register';
var COMMAND_AUTHID = '/authid';
var COMMAND_REVOKE = '/revoke';

var COMMAND_PLAYERS = '/players';

var BOT_CHANNEL = '727589029025022031';
var RP_CHANNEL = '736643905952415856';

var playersList = [];
var serverIsOnline = false;

client.on('ready', () => {
  console.log(`Connect: ${client.user.tag}!`);
  client.user.setStatus("online");

  changeDiscordInfo();

  setInterval(function() { 
    changeDiscordInfo();
  }, 30000);


	http.createServer(function (req, res) {
	        const msg = url.parse(req.url, true).query.msg;
	        client.channels.cache.get(RP_CHANNEL).send(msg);
	        res.end();
	}).listen(54321);

});
client.on('error', console.error);
client.login('NTIyNDU2OTMwMTQxMzM5NjU5.XvzmCg.YPZy7xBLoU-P2_m_L4MnuSyJmkE');

function changeDiscordInfo() {
  Gamedig.query({
    type: 'css',
    host: 'rp.riplay.fr', 
    port: 27015,
    socketTimeout: 5000,
    debug: false
  }).then((state) => {
      let tmp = "Roleplay: " + state.players.length + "/" + state.maxplayers;
      client.user.setActivity(tmp);

      playersList = [];
      state.players.forEach(player => {
        playersList.push(player);
      });

      serverIsOnline = true;
  }).catch((error) => {
    client.user.setActivity("Server offline ...");

    serverIsOnline = false;
  });
}

client.on('guildMemberAdd', member => {
  var id = member.id;

  var riplay = new RiplayMember(id);
  var authid = riplay.getSteamID();

  authid.then(function(value) {
    if(value != null) {
      member.send("ok");

      let role = member.guild.roles.cache.find(r => r.id == '727990402598174791');
      member.roles.add(role);
    } else {
      var message = "Bienvenue sur le serveur **Discord RIPLAY.FR - RolePlay sur CSGO.**" + 
                "\nAfin de pouvoir associer ton compte Discord à ton compte Steam (relié au serveur csgo et au forum/site) rend toi dès maintenant dans le channel `#bot` et tape la commande suivante :" +
                "`/register`" + 
                
                "\n\nDès lors, tu pourras bénéficier de l’ensemble des services proposés et naviguer librement sur ce Discord." + 
                "\n\nLis le règlement dans le channel Bienvenue et reste informé de l'évolution du serveur via le channel Annonces ainsi que sur notre Forum Riplay.fr !" + 
                "\n\nBon jeu à toi et à bientôt sur le serveur !" + 

                "\n\n**TEAM RIPLAY**";
      member.send(message);
    }
  });
});

client.on('message', msg => {
  channelid = msg.channel.id;

  if(channelid == RP_CHANNEL && msg.author.id != client.user.id) {
	 msgToRP(msg);
  }

  if(channelid == BOT_CHANNEL) {
    if (msg.content == COMMAND_REGISTER) {
    		msgRegister(msg);
    }

    if (msg.content == COMMAND_AUTHID) {
    		msgGetAuthid(msg);
    }

    if(msg.content == COMMAND_REVOKE) {
        msgRevoke(msg);
    }

    if(msg.content == COMMAND_PLAYERS) {
      msgPlayers(msg);
    }
  }
});

function msgPlayers(message) {
  message.delete();

  if(!serverIsOnline) {
    message.reply("Le serveur est hors ligne ...");
    return;
  }

  let tmp = '';

  for(let player of playersList) {
    if(player.name == 'undefined' || player.name == '@everyone' || player.name == '@here') {
      player.name = ":poop:";
    }

    tmp = tmp + ' - ' + "[" + player.name + "]";
  }

  message.reply(tmp);
}

function msgToRP(message) {
	var author = message.author.username;
	var content = message.content;

	var msg = encodeURI("{green}" +author +"{default}: "+ content);

	request("http://5.196.39.48:8080/live/msg/"+msg);
}

function msgRevoke(message) {
    var author = message.author;
    var id = author.id;

    var riplay = new RiplayMember(id);
    var revoke = riplay.revoke();

    revoke.then(function(value) {
      if(value == true) {
        message.reply('Vous avez supprimé votre liaison Steam <=> Discord');
      }
    });

    message.delete();
}

function msgRegister(message) {
    var author = message.author;
    var id = author.id;

    var riplay = new RiplayMember(id);
    var register = riplay.register();

    register.then(function(value) {
    	if(value != null) {
    		message.reply('Psssttt regarde tes messages privés :)');
    		sendTokens(author, value, riplay.getRegisterUrl());
    	} else {
        var steamid = riplay.getSteamID();

        steamid.then(function(value) {
          if(value != null) {
            message.reply('Votre compte est relié au SteamID: **' + value + '**');
          }
        });
      }
    });

    message.delete();
}

function msgGetAuthid(msg) {
	var author = msg.author;
  var id = author.id;

	var riplay = new RiplayMember(id);
  var authid = riplay.getSteamID();

  authid.then(function(value) {
  	if(value != null) {
  		msg.reply('Votre compte est relié au SteamID: **' + value + '**');
  	} else {
  		msg.reply('Tapez **'+ COMMAND_REGISTER + '** pour synchroniser votre comtpe');
  	}
  });

  msg.delete();
}

// ----------------------------------------------------------------------------------------------------------------------------------

function sendTokens(author, tokens, url) {
	var explain = " . Votre tokens: **" + tokens + "**" + "\n" + 
				  " . URL Web: **" + url + "**" + "\n\n" + 
				  "Redirigez-vous vers l'URL, connectez-vous avec Steam." + "\n" +
				  "Une fois connecté, copié/collé le Tokens";


	const embed = new Discord.MessageEmbed()
		.setColor('#0099ff')
		.setTitle('Suivez ces instructions pour synchroniser votre compte Steam:')
		//.setURL('http://')
		//.setAuthor('Synchronisation Steam<=>Discord')
		.setDescription(explain)
		.setTimestamp()
		.setFooter('Votre token expire dans 1heure');

		author.send(embed);
}
