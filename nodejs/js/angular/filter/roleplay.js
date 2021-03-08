"use strict";
exports = module.exports = function(app) {

  app.filter('prettyBan', function() {
    return function(game) {
      switch(game) {
        case "csgo": return "a été interdit de jouer à nos serveurs CSGO";
        case "forum": return "a été interdit d'utiliser notre forum";

        case "ALL": return "a été bannis notre communauté";

        case "rp-local": return "a été interdit de parler dans le chat local";
        case "rp-global": return "a été interdit de parler dans chat global";
        case "rp-vocal": return "a été interdit de parler dans chat vocal";
        case "rp-event": return "a été interdit de participer à des events";
        case "rp-pvp": return "a été interdit de participer aux captures PvP et d'être dans un gang";
        case "rp-kill": return "a été interdit de commettre des meurtres";
        case "rp-give": return "a été interdit de donner de l'argent aux autres joueurs";

        case "tribunal": return "a été mis en prison";

      }
      return game;
    };
  });
  app.filter('num', function() {
    return function(input) {
       return parseInt(input, 10);
    }
  });
  app.filter('parselog', function ($sce) {
     return function (item, filtre) {
       var str = item.replace(filtre, "<i class='text-primary'>"+filtre+"</i>");
       return $sce.trustAsHtml(str.replace(/(STEAM_1:[0-1]:[0-9]{1,14})/g, "<b class='text-primary'>$1</b>"));
     };
   });
   app.filter("trust", ['$sce', function($sce) { return function(htmlCode){ return $sce.trustAsHtml(htmlCode); }}]);
   app.filter('fullDuration', function () {
     return function(seconds) {
       var days = Math.floor(seconds / 86400);
       var hours = Math.floor((seconds % 86400) / 3600);
       var minutes = Math.floor(((seconds % 86400) % 3600) / 60);
       seconds = Math.floor(((seconds % 86400) % 3600) % 60);

       var str = '';
       if ((days > 0) && (hours === 0 && minutes === 0 && seconds === 0)) str += (days > 1) ? (days + ' jours ') : (days + ' jour ');
       if ((days > 0) && (hours > 0 || minutes > 0 || seconds > 0)) str += (days > 1) ? (days + ' jours, ') : (days + ' jour, ');
       if ((hours > 0) && (minutes > 0 || seconds > 0 )) str += (hours > 1) ? (hours + ' heures, ') : (hours + ' heure, ');
       if ((hours > 0) && (minutes === 0 && seconds === 0 )) str += (hours > 1) ? (hours + ' heures ') : (hours + ' heure ');
       if ((minutes > 0) && (seconds > 0)) str += (minutes > 1) ? (minutes + ' minutes, ') : (minutes + ' minute, ');
       if ((minutes > 0) && (seconds === 0)) str += (minutes > 1) ? (minutes + ' minutes ') : (minutes + ' minute ');
       if (seconds > 0) str += (seconds > 1) ? (seconds + ' secondes ') : (seconds + ' seconde ');
       return str.trim();
     };
   });
   app.filter('duration', function () {
     return function(seconds) {
       var days = Math.floor(seconds / 86400);
       var hours = Math.floor(seconds / 3600);
       var minutes = Math.floor((seconds % 3600) / 60);
       var str = '';
       if ((hours > 0) && (minutes > 0 || seconds > 0 )) str += (hours > 1) ? (hours + ' heures, ') : (hours + ' heure, ');
       if ((hours > 0) && (minutes === 0 && seconds === 0 )) str += (hours > 1) ? (hours + ' heures ') : (hours + ' heure ');
       if ((minutes > 0)) str += (minutes > 1) ? (minutes + ' minutes ') : (minutes + ' minute ');
       return str;
      };
    });

};
