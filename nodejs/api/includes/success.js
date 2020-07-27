"use strict";
exports = module.exports = function(server){
  var ERR = require('node-restify-errors');
  var moment = require('moment');
  var request = require('request');
  var successData = require('./data/success.json');
  var gd = require('node-gd');
  var fs = require('fs');

/**
   * @api {get} /success/
   * @apiGroup Success
   */
  server.get('/success/', function (req, res, next) {
    var obj = [];
    var success = [];

    successData.forEach(item => {
      console.log(success);

      success = {
        id: item[0],
        name: item[1],
        desc: item[2],
        need_to_unlock: item[3],
        max_achieved: item[4]
      };

      obj.push(success);
    });
    return res.send(obj);
  });

  //next();
};