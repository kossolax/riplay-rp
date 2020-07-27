"use strict";
exports = module.exports = function(app) {

  app.config(function($routeProvider, $locationProvider) {
    $routeProvider.when('/tribunal/:arg/:sub', {
      templateUrl: function(p) { return "/templates/node/roleplay_tribunal_"+p.arg+".tpl"; },
      controller: 'rpTribunalCase',
      reloadOnSearch: false
    }).when('/tribunal/:arg', {
      templateUrl: function(p) { return "/templates/node/roleplay_tribunal_"+p.arg+".tpl"; },
      controller: 'rpTribunal',
      reloadOnSearch: false
    }).when('/pilori/:arg/:sub', {
      templateUrl: function(p) { return "/templates/node/roleplay_pilori_"+p.arg+".tpl"; },
      controller: 'rpPiloriCase',
      reloadOnSearch: false
    }).when('/pilori/:arg', {
      templateUrl: function(p) { return "/templates/node/roleplay_pilori_"+p.arg+".tpl"; },
      controller: 'rpPiloriCase',
      reloadOnSearch: false
    }).when('/hdv/:arg', {
      templateUrl: function(p) { return "/templates/node/roleplay_hdv.tpl"; },
      controller: 'rpHDV',
      reloadOnSearch: false
    }).when('/:arg/:sub', {
      templateUrl: function(p) { return "/templates/node/roleplay_"+p.arg+".tpl"; },
      controller: 'rpJobGang',
      reloadOnSearch: false
    }).when('/map', {
      templateUrl: function(p) { return "/templates/node/roleplay_map.tpl"; },
      controller: 'rpMap',
      reloadOnSearch: false
    }).when('/search', {
      templateUrl: function(p) { return "/templates/node/roleplay_search.tpl"; },
      reloadOnSearch: false
    }).when('/graph/:arg', {
      templateUrl: function(p) { return "/templates/node/roleplay_graph.tpl"; },
      reloadOnSearch: false
    }).when('/update', {
      templateUrl: function(p) { return "/templates/node/roleplay_update.tpl"; },
      controller: 'rpUpdate',
      reloadOnSearch: false
    }).when('/test', {
      templateUrl: function(p) { return "/templates/node/roleplay_test.tpl"; },
      controller: 'rpTest',
      reloadOnSearch: false

    }).when('/success/:arg', {
      templateUrl: function(p) { return "/templates/node/roleplay_success.tpl"; },
      reloadOnSearch: false,
      controller: 'rpSuccess'
    }).when('/success/', {
      templateUrl: function(p) { return "/templates/node/roleplay_success.tpl"; },
      reloadOnSearch: false,
      controller: 'rpSuccess'
    }).when('/success', {
      templateUrl: function(p) { return "/templates/node/roleplay_success.tpl"; },
      reloadOnSearch: false,
      controller: 'rpSuccess'

    }).when('/donation', {
      templateUrl: function(p) { return "/templates/node/roleplay_donation.tpl"; },
      controller: 'rpDonation',
      reloadOnSearch: false

    }).when('/', {
      templateUrl: function(p) { 
        return "/templates/node/roleplay.tpl"; 
      },
      controller: 'rpIndex',
      reloadOnSearch: false
    });
  });

};
