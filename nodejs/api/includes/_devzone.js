"use strict";
exports = module.exports = function(server){
  var ERR = require('node-restify-errors');
  var moment = require('moment');
  var dz = require('./user.devzone.js');
  /**
   * @api {get} /devzone/user GetUser
   * @apiName GetUser
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   */
  server.get('/devzone/user', function (req, res, next) {
    dz.user(server, req.headers.auth, function(user){
      return res.send({
        username:    user.username,
        uid:         user.uid,
        gid:         user.gid,
        accesslevel: user.accesslevel,
        accessname:  user.accessname,
        assigne:     user.assigne
      });
    });
    next();
  });
  
  /**
   * @api {get} /devzone/user/:id GetUserNameById
   * @apiName GetUser
   * @apiGroup DevZone
   */
  server.get('/devzone/user/:id', function (req, res, next) {
    var cache = server.cache.get( req._url.pathname);
    if( cache !== undefined ) { return res.send(cache); }
    dz.IdToName(server, req.params.id, function(ret){
      server.cache.set( req._url.pathname, {username: ret});
      return res.send({username: ret});
    });
    next();
  });
  
  /**
   * @api {get} /devzone/status GetStatus
   * @apiName GetStatus
   * @apiGroup DevZone
   */
  server.get('/devzone/status', function (req, res, next) {
    var cache = server.cache.get( req._url.pathname);
    if( cache !== undefined ) { return res.send(cache); }
    var ret = {};

    var sql = "SELECT S.stat_id, S.stat_name, S.stat_priority, UNIX_TIMESTAMP(S.stat_date) stat_date, S.stat_hidden FROM `leeth`.dz_status S ORDER BY stat_hidden ASC,stat_priority DESC";
    server.conn.query(sql, [], function(err, rows){
      if( err ) res.send(new ERR.InternalServerError(err));
      for (var i = 0; i < rows.length; i++) {
          ret[ rows[i].stat_id ] = rows[i];
      }
      server.cache.set( req._url.pathname, ret);
      return res.send(ret);
    });
    next();
  });
  
  /**
   * @api {get} /devzone/category GetCategories
   * @apiName GetCategories
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   */
   server.get('/devzone/category', function (req, res, next) {
     dz.user(server, req.headers.auth,function(user){
       var cache = server.cache.get( req._url.pathname+'-'+user.accesslevel );
       if( cache !== undefined ) { return res.send(cache); }
       var ret = {};
       
       var sql = "SELECT cat_id,cat_name,cat_color,cat_prio,cat_minacc FROM `leeth`.dz_cat WHERE cat_minacc <= ? ORDER BY cat_prio DESC;";
       server.conn.query(sql, [user.accesslevel], function(err, rows){
         if( err ) res.send(new ERR.InternalServerError(err));
         for (var i = 0; i < rows.length; i++) {
             ret[ rows[i].cat_id ] = rows[i];
         }
         server.cache.set( req._url.pathname+'-'+user.accesslevel , ret);
         return res.send(ret);
       });
     });
     next();
   });
  
  /**
   * @api {get} /devzone/ticket GetTickets
   * @apiName GetTickets
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   */
  server.get('/devzone/ticket', function (req, res, next) {
    dz.user(server, req.headers.auth,function(user){
      var cache = server.cache.get( req._url.pathname+'-'+user.accesslevel );
      if( cache !== undefined ) { return res.send(cache); }
      
      var sql = "SELECT S.stat_id, tk_id, tk_title, usr_id, assig_usr_id, tk_desc, tk_showdesc, T.cat_id, tk_url FROM `leeth`.dz_status S ";
        sql +="LEFT JOIN `leeth`.dz_ticket T ON T.stat_id = S.stat_id ";
	    sql +="LEFT JOIN `leeth`.dz_cat C ON T.cat_id = C.cat_id ";
	    sql +="WHERE C.cat_minacc <= ? AND ";
	    sql +="S.stat_id IN(SELECT * FROM (SELECT S.stat_id FROM `leeth`.dz_status S ORDER BY stat_hidden ASC,stat_priority DESC LIMIT 4) AS temp) ";
	    sql +="ORDER BY stat_hidden ASC,stat_priority DESC,cat_prio DESC,IFNULL(tk_prio,0) ASC;";
      server.conn.query(sql, [user.accesslevel], function(err, rows){
        if( err ) res.send(new ERR.InternalServerError(err));
        server.cache.set( req._url.pathname+'-'+user.accesslevel , rows);
        return res.send(rows);
      });
    });
    next();
  });
  
  /**
   * @api {get} /devzone/ticket/:id GetTicketById
   * @apiName GetTicketById
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {int} id L'id du ticket.
   */
  server.get('/devzone/ticket/:id', function (req, res, next) {
    
    if( req.params.id === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
      
    dz.user(server, req.headers.auth,function(user){
      var cache = server.cache.get( req._url.pathname+'-'+user.accesslevel );
      if( cache !== undefined ) { return res.send(cache); }
      
      var sql = "SELECT T.tk_id, T.stat_id, stat_name, T.cat_id, cat_name, cat_minacc, tk_ava, tk_esttime, tk_title, tk_desc, tk_showdesc, T.usr_id AS 'usr_id',";
        sql+=" assig_usr_id, UNIX_TIMESTAMP(tk_datecrea) AS tk_datecrea, UNIX_TIMESTAMP(tk_dateend) AS tk_dateend, tk_url ";
        sql+="FROM `leeth`.dz_ticket T NATURAL JOIN `leeth`.dz_status S NATURAL JOIN `leeth`.dz_cat C WHERE T.tk_id = ? AND C.cat_minacc <= ?;";
      server.conn.query(sql, [req.params.id, user.accesslevel], function(err, rows){
        if( err ) res.send(new ERR.InternalServerError(err));

        if(rows.length === 0)
          return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

        server.cache.set( req._url.pathname+'-'+user.accesslevel , rows);
        return res.send(rows);
      });
    });
    next();
  });
  
  /**
   * @api {get} /devzone/ticket/:id/comment GetCommentsById
   * @apiName GetCommentsById
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {int} id L'id du ticket.
   */
  server.get('/devzone/ticket/:id/comment', function (req, res, next) {
    
    if( req.params.id === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
      
    dz.user(server, req.headers.auth,function(user){
      var cache = server.cache.get( req._url.pathname+'-'+user.accesslevel );
      if( cache !== undefined ) { return res.send(cache); }
      
      var sql = "SELECT com_id, com_text, C.usr_id ";
        sql  +="FROM `leeth`.dz_comment C INNER JOIN `leeth`.dz_ticket T ON T.tk_id = C.tk_id INNER JOIN `leeth`.dz_cat K ON K.cat_id = T.cat_id ";
        sql  +="WHERE C.tk_id=? AND K.cat_minacc <= ? ORDER BY com_id ASC;";
      server.conn.query(sql, [req.params.id, user.accesslevel], function(err, rows){
        if( err ) res.send(new ERR.InternalServerError(err));

        server.cache.set( req._url.pathname+'-'+user.accesslevel , rows);
        return res.send(rows);
      });
    });
    next();
  });
  
  /**
   * @api {get} /devzone/assigne GetAssigne
   * @apiName GetAssigne
   * @apiGroup DevZone
   */
  server.get('/devzone/assigne', function (req, res, next) {
    var cache = server.cache.get(req._url.pathname);
    if( cache !== undefined ) { return res.send(cache); }
    
    var sql = 'SELECT st_val FROM `leeth`.dz_settings WHERE st_key="assig"';
    server.conn.query(sql, [], function(err, rows){
      if( err ) res.send(new ERR.InternalServerError(err));
      var ret = JSON.parse(rows[0].st_val);
      server.cache.set(req._url.pathname, ret);
      return res.send(ret);
    });
    next();
  });
  
  /**
   * @api {put} /devzone/assigne PutAssigne
   * @apiName PutAssigne
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {String} user Le pseudo forum de la personne.
   */
  server.put('/devzone/assigne', function (req, res, next) {

    if( req.params.user === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
      
    dz.user(server, req.headers.auth,function(user){
      
      if(!user.hasaccess(50))
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
        
      var sql = 'SELECT st_val FROM `leeth`.dz_settings WHERE st_key="assig"';
      server.conn.query(sql, [], function(err, rows){
        if( err ) res.send(new ERR.InternalServerError(err));
        
        var ret = JSON.parse(rows[0].st_val);
        dz.NameToId(server, req.params.user, function(pid){
          if(pid == 1)
            return res.send(new ERR.NotFoundError("NotFound"));
          for(var i=0; i<ret.length; i++){
            if(ret[i] == pid)
              return res.send('OK');
          }
          ret[ret.length] = pid;
          var sql2 = 'UPDATE `leeth`.dz_settings SET st_val=? WHERE st_key="assig";';
          server.conn.query(sql2, [JSON.stringify(ret)], function(err2, rows2){
            if( err2 ) 
              return res.send('UPDATE ERROR');
              
            server.cache.del("/devzone/assigne");
            return res.send('OK');
          });
        });

      });
    });
    next();
  });
  
  /**
   * @api {delete} /devzone/assigne/:userid DelAssigne
   * @apiName DelAssigne
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {int} userid L'id forum de la personne.
   */
  server.del('/devzone/assigne/:userid', function (req, res, next) {

    if( req.params.userid === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
      
    dz.user(server, req.headers.auth,function(user){
      
      if(!user.hasaccess(50))
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
        
      var sql = 'SELECT st_val FROM `leeth`.dz_settings WHERE st_key="assig"';
      server.conn.query(sql, [], function(err, rows){
        if( err ) res.send(new ERR.InternalServerError(err));
        
        var ret = JSON.parse(rows[0].st_val);

        for(var i=0; i<ret.length; i++){
          if(ret[i] != req.params.userid)
            continue;
            
          ret.splice(i, 1);
          break;
        }
        
        var sql2 = 'UPDATE `leeth`.dz_settings SET st_val=? WHERE st_key="assig";';
        server.conn.query(sql2, [JSON.stringify(ret)], function(err2, rows2){
          if( err2 ) 
            return res.send('UPDATE ERROR');
            
          server.cache.del("/devzone/assigne");
          return res.send('OK');
        });

      });
    });
    next();
  });
  
  /**
   * @api {delete} /devzone/ticket/:id DelTicket
   * @apiName DelTicket
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {int} id L'id du ticket.
   * @apiParam {String} reason La raison de la supression
   */
  server.del('/devzone/ticket/:id', function (req, res, next) {

    if( req.params.id === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
      
    dz.user(server, req.headers.auth,function(user){
        
      var sql = 'SELECT usr_id, tk_title, stat_id FROM `leeth`.dz_ticket WHERE tk_id=?';
      server.conn.query(sql, [req.params.id], function(err, rows){
        if( err ) res.send(new ERR.InternalServerError(err));
        if( rows.length === 0 ) return res.send(new ERR.NotFoundError("NotFound"));
        
        var tkOwner = rows[0].usr_id;
        
        if(!user.hasaccess(40)){
          if(user.uid != tkOwner){
            return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
          }
          else{
            if(rows[0].stat_id != 1)
              return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
          }
        }
        
        if(tkOwner != user.uid){
          var msg = 'Votre ticket <span style="font-weight: bold">'+ rows[0].tk_title +'</span> à été suprimmé par l\'admin <span style="font-weight: bold">'+ user.username +'</span>';
          if(req.params.reason !== undefined)
            msg += ' pour le motif: <span style="font-style: italic">'+ req.params.reason +'</span>';
          dz.pm(server, tkOwner, "Supression de votre ticket" + rows[0].tk_title, msg);
        }
          
        var sql2 = 'DELETE FROM `leeth`.dz_ticket WHERE tk_id=?;';
        server.conn.query(sql2, [req.params.id], function(err2, rows2){
          if( err2 ) res.send(new ERR.InternalServerError(err2));

          for(var i=0; i<=100; i+=10)
            server.cache.del("/devzone/ticket-"+i);
          server.cache.del("/devzone/ticket/" + req.params.id);

          return res.send('OK');
        });

      });
    });
    next();
  });
  
  /**
   * @api {delete} /devzone/ticket/:id/comment/:cid DelComment
   * @apiName DelComment
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {int} id L'id du ticket.
   * @apiParam {int} cid L'id du commentaire.
   */
  server.del('/devzone/ticket/:id/comment/:cid', function (req, res, next) {

    if( req.params.id === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.cid === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
      
    dz.user(server, req.headers.auth,function(user){
      if(!user.hasaccess(40))
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
        
      var sql = 'DELETE FROM `leeth`.dz_comment WHERE com_id=? AND tk_id=?;';
      server.conn.query(sql, [req.params.cid, req.params.id], function(err, rows){
        if( err ) res.send(new ERR.InternalServerError(err));
        for(var i=0; i<=100; i+=10)
          server.cache.del("/devzone/ticket/"+ req.params.id +"/comment-"+i);
        return res.send('OK');
      });

    });
    next();
  });
  
  /**
   * @api {put} /devzone/ticket PutTicket
   * @apiName PutTicket
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {String} title Le titre du ticket.
   * @apiParam {int} job Le job qu'il concerne (0 = pas lié à un job)
   * @apiParam {String} desc La description du ticket.
   * @apiParam {String} url Un lien vers le forum.
   * @apiParam {String} showdesc Afficher la description?
   * @apiParam {int} category La categorie.
   */
  server.put('/devzone/ticket', function (req, res, next) {

    if( req.params.title === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.job === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.category === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.headers.auth === undefined )
      return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      
    dz.user(server, req.headers.auth,function(user){
        
      if(!user.hasaccess(10))
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      
      var showdesc = (req.params.showdesc === undefined || req.params.showdesc === '') ? 0 : 1;
      var tk_url = req.params.url || '';
      var ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress || req.socket.remoteAddress || req.connection.socket.remoteAddress;
      
      var sql = "INSERT INTO `leeth`.dz_ticket(stat_id, cat_id, tk_title, tk_desc, tk_showdesc, assig_usr_id, tk_ip, usr_id, tk_url, tk_esttime) VALUES ";
      sql  += "(1, ?, ?, ?, ?, 0, ?, ?, ?, ?)";
  
      server.conn.query(sql, [req.params.category, req.params.title, req.params.desc, showdesc, ip, user.uid, tk_url, req.params.job], function(err, rows){
        if( err ) res.send(new ERR.InternalServerError(err));
        
        for(var i=0; i<=100; i+=10)
          server.cache.del("/devzone/ticket-"+i);
          
        return res.send('ok');
      });
    });
    next();
  });  
  
  /**
   * @api {put} /devzone/ticket/:id/comment PutComment
   * @apiName PutComment
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {int} id L'id du ticket.
   * @apiParam {string} text Le commentaire.
   */
  server.put('/devzone/ticket/:id/comment', function (req, res, next) {

    if( req.params.id === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.text === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.headers.auth === undefined )
      return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      
    dz.user(server, req.headers.auth,function(user){
      if(user.uid == 1)
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));

      var sql = 'SELECT cat_minacc, tk_title, usr_id FROM `leeth`.dz_ticket T INNER JOIN `leeth`.dz_cat C ON T.cat_id = C.cat_id WHERE tk_id=?';
      server.conn.query(sql, [req.params.id], function(err, rows){
        if(err) res.send(new ERR.InternalServerError(err));
        if(rows[0] === undefined)
          return res.send(new ERR.NotFoundError("NotFound"));
        if(!user.hasaccess(rows[0].cat_minacc))
          return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
          
        var ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress || req.socket.remoteAddress || req.connection.socket.remoteAddress;
        var sql2 = 'INSERT INTO `leeth`.dz_comment(com_text, usr_id, com_ip, tk_id) VALUES ';
        sql2 += '(?, ?, ?, ?)';
        server.conn.query(sql2, [req.params.text, user.uid, ip, req.params.id], function(err2, rows2){
          if(err2) res.send(new ERR.InternalServerError(err2));
          var sql3 = "SELECT DISTINCT usr_id FROM `leeth`.dz_comment WHERE tk_id=? AND usr_id!=? AND usr_id!=?";
          server.conn.query(sql3, [req.params.id, user.uid, rows[0].usr_id], function(err3, rows3){
            if(err3) res.send(new ERR.InternalServerError(err3));
            
            var msg = 'Un commentaire à été ajouté au ticket <span style="font-weight: bold">'+ rows[0].tk_title +'</span> par <span style="font-weight: bold">' + user.username + '</span>.';
            var sent = [];
            if(rows[0].usr_id != user.uid){
              sent[sent.length] = rows[0].usr_id;
              dz.pm(server, rows[0].usr_id, "Ajout d'un commentaire au ticket: " + rows[0].tk_title, msg);
            }
            for(let i=0; i<rows3.length; i++){
              if(rows[0].usr_id == rows3[i].usr_id)
                continue;
              if(sent.indexOf(rows3[i].usr_id) != -1)
                continue;
              sent[sent.length] = rows3[i].usr_id;
              dz.pm(server, rows3[i].usr_id, "Ajout d'un commentaire au ticket: " + rows[0].tk_title, msg);
            }
            for(let i=0; i<=100; i+=10)
              server.cache.del("/devzone/ticket/"+ req.params.id +"/comment-"+i);
            
            return res.send('ok');
          });
        });
      });
    });
    next();
  });  
  
  /**
   * @api {post} /devzone/ticket/:id PostTicket
   * @apiName PostTicket
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {int} id L'id du ticket a modifier.
   * @apiParam {String} title Le titre du ticket.
   * @apiParam {int} job Le job qu'il concerne (0 = pas lié à un job)
   * @apiParam {int} assig L'id de la personne qui se charge du ticket
   * @apiParam {int} avancement L'avancement du ticket (Compris entre 1 et 100)
   * @apiParam {String} desc La description du ticket.
   * @apiParam {String} url Un lien vers le forum.
   * @apiParam {String} showdesc Afficher la description?
   * @apiParam {int} category La categorie.
   */
  server.post('/devzone/ticket/:id', function (req, res, next) {

    if( req.params.id === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.title === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.job === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.assig === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.avancement === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.desc === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.category === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));

    dz.user(server, req.headers.auth,function(user){
      if(user.uid == 1)
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
      
      var sql = 'SELECT usr_id, tk_title, stat_id, assig_usr_id FROM `leeth`.dz_ticket WHERE tk_id=? LIMIT 1';
      server.conn.query(sql, [req.params.id], function(err, rows){
        
        if(!user.hasaccess(40)){
          if(user.uid != rows[0].usr_id){
            return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
          }
          else{
            if(rows[0].stat_id != 1)
              return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
          }
        }
        
        var showdesc = (req.params.showdesc === undefined || req.params.showdesc === '') ? 0 : 1;
        var tk_url = req.params.url || '';
        
        var sql = "UPDATE `leeth`.dz_ticket SET ";
          sql  += "cat_id=?, tk_title=?, tk_desc=?, tk_showdesc=?, assig_usr_id=?, tk_url=?, tk_esttime=?, tk_ava=? ";
          sql  += "WHERE tk_id=?";
        
        server.conn.query(sql, [req.params.category, req.params.title, req.params.desc, showdesc, req.params.assig, tk_url, req.params.job, req.params.avancement, req.params.id], function(err, rows2){
          if( err ) res.send(new ERR.InternalServerError(err));
          
          for(var i=0; i<=100; i+=10)
            server.cache.del("/devzone/ticket-"+i);
          server.cache.del("/devzone/ticket/" + req.params.id);
          
          var msg = '';
          if(user.uid != rows[0].usr_id){
            if(rows[0].usr_id != req.params.assig){
              msg = 'Votre ticket <span style="font-weight: bold">'+ rows[0].tk_title +'</span> à été modifié par <span style="font-weight: bold">' + user.username + '</span>.';
              dz.pm(server, rows[0].usr_id, "Modification du ticket: " + rows[0].tk_title, msg);
            }
          }
          if(req.params.assig != '0'){
            if(user.uid != req.params.assig){
              if(rows[0].assig_usr_id != req.params.assig){
                msg = 'Le ticket <span style="font-weight: bold">'+ rows[0].tk_title +'</span> vous a été assigné par <span style="font-weight: bold">' + user.username + '</span>.';
                dz.pm(server, req.params.assig, "Assignation au ticket: " + rows[0].tk_title, msg);
              }
              else{
                msg = 'Le ticket <span style="font-weight: bold">'+ rows[0].tk_title +'</span> auquel vous êtes assignés a été modifié par <span style="font-weight: bold">' + user.username + '</span>.';
                dz.pm(server, req.params.assig, "Modification du ticket: " + rows[0].tk_title, msg);
              }
            }
          }
          return res.send('ok');
        });
      });
    });
    next();
  });
  
  /**
   * @api {delete} /devzone/status/:statid DelStatus
   * @apiName DelStatus
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {int} statid L'id de la maj.
   */
  server.del('/devzone/status/:statid', function (req, res, next) {

    if( req.params.statid === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
      
    dz.user(server, req.headers.auth,function(user){
      
      if(!user.hasaccess(50))
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
        
      var sql = 'SELECT stat_hidden,(SELECT count(tk_id) FROM `leeth`.dz_ticket WHERE stat_id=?) AS tk_num FROM `leeth`.dz_status WHERE stat_id=?';
      server.conn.query(sql, [req.params.statid, req.params.statid], function(err, rows){
        if( err ) res.send(new ERR.InternalServerError(err));
        if(rows.length === 0)
          return res.send(new ERR.NotFoundError("NotFound"));
        if(rows[0].stat_hidden == '0')
          return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
        if(rows[0].tk_num > 0)
          return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
          
        var sql2 = "DELETE FROM `leeth`.dz_status WHERE stat_id=?";
        server.conn.query(sql2, [req.params.statid], function(err2, rows2){
          if( err2 ) res.send(new ERR.InternalServerError(err2));
          return res.send('OK');
        });
      });
    });
    next();
  });
  
  /**
   * @api {delete} /devzone/category/:catid DelCategory
   * @apiName DelCategory
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {int} catid L'id de la categorie.
   */
  server.del('/devzone/category/:catid', function (req, res, next) {

    if( req.params.catid === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
      
    dz.user(server, req.headers.auth,function(user){
      
      if(!user.hasaccess(50))
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
        
      var sql = 'SELECT count(tk_id) AS tk_num FROM `leeth`.dz_ticket WHERE cat_id=?';
      server.conn.query(sql, [req.params.catid], function(err, rows){
        if( err ) res.send(new ERR.InternalServerError(err));
        if(rows[0].tk_num > 0)
          return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
          
        var sql2 = "DELETE FROM `leeth`.dz_cat WHERE cat_id=?";
        server.conn.query(sql2, [req.params.catid], function(err2, rows2){
          if( err2 ) res.send(new ERR.InternalServerError(err2));
          return res.send('OK');
        });
      });
    });
    next();
  });
  
  /**
   * @api {put} /devzone/status PutStatus
   * @apiName PutStatus
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {String} name Le nom de la maj.
   * @apiParam {String} moveall Déplacer tout les tickets.
   */
  server.put('/devzone/status', function (req, res, next) {

    if( req.params.name === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
      
    dz.user(server, req.headers.auth,function(user){
      
      if(!user.hasaccess(50))
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
        
      var sql = 'INSERT INTO `leeth`.dz_status(stat_name, stat_priority, stat_hidden) VALUES ';
        sql  += '(?, (SELECT (SELECT IFNULL(max(stat_priority),0)+10 a FROM dz_status WHERE stat_hidden=1) AS temp), 1)';
      server.conn.query(sql, [req.params.name], function(err, rows){
        if( err ) res.send(new ERR.InternalServerError(err));
        var moveall = (req.params.moveall === undefined || req.params.moveall === '');
        if(!moveall)
          return res.send('OK');
        
        var sql2 = 'UPDATE dz_ticket SET stat_id=? WHERE stat_id=4';
        server.conn.query(sql, [rows.insertId], function(err2, rows2){
          if(err2) res.send(new ERR.InternalServerError(err2));
          return res.send('OK');
        });
      });
    });
    next();
  });
  
  /**
   * @api {put} /devzone/category PutCategory
   * @apiName PutCategory
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {String} name Le nom de la catégorie.
   * @apiParam {String} color La couleur css de la catégorie.
   * @apiParam {int} prio La priorité de la catégorie.
   * @apiParam {int} minacc Le niveau minimum d'accès pour voir la catégorie.
   */
  server.put('/devzone/category', function (req, res, next) {

    if( req.params.name === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.color === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.prio === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.minacc === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
      
    dz.user(server, req.headers.auth,function(user){
      
      if(!user.hasaccess(50))
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
        
      var sql = 'INSERT INTO `leeth`.dz_cat(cat_name, cat_priority, cat_color, cat_minacc) VALUES';
        sql  += '(?, ?, ?, ?)';
      server.conn.query(sql, [req.params.name, req.params.prio, req.params.color, req.params.minacc], function(err, rows){
        if( err ) res.send(new ERR.InternalServerError(err));
        return res.send('OK');
      });
    });
    next();
  });
  
  /**
   * @api {post} /devzone/category/:cid PostCategory
   * @apiName PostCategory
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {int} cid L'id de la catégorie.
   * @apiParam {String} name Le nom de la catégorie.
   * @apiParam {String} color La couleur css de la catégorie.
   * @apiParam {int} prio La priorité de la catégorie.
   * @apiParam {int} minacc Le niveau minimum d'accès pour voir la catégorie.
   */
  server.post('/devzone/category/:cid', function (req, res, next) {

    if( req.params.cid === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.name === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.color === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.prio === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.minacc === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
      
    dz.user(server, req.headers.auth,function(user){
      
      if(!user.hasaccess(50))
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
        
      var sql = 'UPDATE `leeth`.dz_cat SET cat_name=?, cat_prio=?, cat_color=?, cat_minacc=? WHERE cat_id=?';
      server.conn.query(sql, [req.params.name, req.params.prio, req.params.color, req.params.minacc, req.params.cid], function(err, rows){
        if( err ) res.send(new ERR.InternalServerError(err));
        return res.send('OK');
      });
    });
    next();
  });
  
  /**
   * @api {post} /devzone/status/:sid PostStatus
   * @apiName PostStatus
   * @apiGroup DevZone
   * @apiHeader {String} auth Votre cookie de connexion.
   * @apiParam {int} sid L'id de la maj.
   * @apiParam {String} name Le nom de la maj.
   * @apiParam {int} prio La priorité de la maj.
   */
  server.post('/devzone/status/:sid', function (req, res, next) {

    if( req.params.sid === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.name === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
    if( req.params.prio === undefined )
      return res.send(new ERR.BadRequestError("InvalidParam"));
      
    dz.user(server, req.headers.auth,function(user){
      
      if(!user.hasaccess(50))
        return res.send(new ERR.NotAuthorizedError("NotAuthorized"));
        
      var sql = 'UPDATE `leeth`.dz_status SET stat_name=?, stat_prio=? WHERE stat_id=?';
      server.conn.query(sql, [req.params.name, req.params.prio, req.params.sid], function(err, rows){
        if( err ) res.send(new ERR.InternalServerError(err));
        return res.send('OK');
      });
    });
    next();
  });
};
