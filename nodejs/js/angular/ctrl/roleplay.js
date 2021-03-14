"use strict";
exports = module.exports = function(app) {

app.controller('rpUpdate', function($scope, $http, $filter, $location, $routeParams) {
  $http.get("https://riplay.fr/api/live/update").then(function(res) { $scope.data = res; });
});

app.controller('mainCtrl', function($scope, $http, $filter, $location, $routeParams, $route, $timeout) {
  document.title = "Riplay.fr | RolePlay - index";
  $scope.Search = $location.search();
  $scope.Params = $routeParams;
  $scope.steamid = _steamid;
  //$scope.isAdmin = (_isAdmin?true:false);
  $scope.isAdmin = false;
  $scope.Math = window.Math;

  $http.get("https://riplay.fr/api/user/admin").then(function(res) {
      $scope.isAdmin = true;
  });

  $scope.isConnectedToForum = _member_id == null || _member_id == '' ? false:true;

  $scope.reloadTimer = function(timer) {
    $timeout( function() {
      $route.reload();
    }, timer);
  }

  $http.get("https://riplay.fr/api/jobs").then(function(res) { 
    $scope.jobs = res.data; 
    //console.log($scope.jobs);
  });
  $http.get("https://riplay.fr/api/groups").then(function(res) { 
    $scope.groups = res.data; 
     //console.log($scope.groups);
  });
  $http.get("https://riplay.fr/api/user/"+$scope.steamid).then(function(res) { 
    $scope.user = res.data; 
     //console.log($scope.groups);
  });

  $("body").popover({ selector: '[data-toggle="popover"]', trigger: "hover", html : true});
  $("body").tooltip({ selector: '[data-toggle="tooltip"]', trigger: "hover"});

  if( $location.search() && $location.search().TABS ) {  setTimeout(function() { $('#'+$location.search().TABS).show(); }, 100); }
  $scope.$watch(function(){return $location.search();}, function(value) {
    $scope.Search = value;
    var tab = value.TABS; $('.tab-pane').hide(); $('#'+tab).show();
  });

  /*$scope.isConnected = function(steam, forum) {
    var pattern = /^[0-9]{17}$/g;
    //console.log(pattern.test(steam));
    if(pattern.test(steam) == false) {
      return 'no_steamid';
    }

    if(forum == '' || isNaN(forum) || forum == ' ' || forum == null) {
      return 'no_forum';
    }

    return 'yes';
  }*/

  $scope.paramsSub = $routeParams.sub;
});
/* page /user/:steamid */
app.controller('rpJobGang', function($scope, $http, $routeParams, $location) {
  if( $routeParams.sub == "notset" ) { $location.path( "/" ); }

  $scope.isAdmin = false;
  $http.get("https://riplay.fr/api/"+$routeParams.arg+"/"+$routeParams.sub).then(function(res) {
    res = res.data;
    document.title = "Riplay.fr | RolePlay - " + res.name;

    $scope.data = res;
    $scope.timeplayed = Math.round(res.timeplayed*10)/10;
    $scope.timeplayedjob = Math.round(res.timePlayedJob*10/(60*60))/10;
    $scope.ratiokilldeath = Math.round(res.kill/res.death*100)/100;
    $scope.steamid64 = _steamid;
    if($scope.ratiokilldeath == null || Number.isNaN($scope.ratiokilldeath)) {
      $scope.ratiokilldeath = 0
    }
  });

  if( $routeParams.arg == "job" || $routeParams.arg == "group" ) {
    $http.get("https://riplay.fr/api/"+$routeParams.arg+"s/"+$routeParams.sub+"/users").then(function(res) {
      $scope.players = res.data;
      $scope.isAdmin = false;
      for(var i=0; i<res.data.length; i++) {
        if( res.data[i].steamid == $scope.$parent.steamid ) {
          $scope.isAdmin = true;
        }
      }
    });

    if( $routeParams.arg == "job" ) {
      $http.get("https://riplay.fr/api/items/job/"+$routeParams.sub).then(function(res) { 
        $scope.items = res.data; 
      });
      $http.get("https://riplay.fr/api/job/"+$routeParams.sub+"/top").then(function(res) { 
        $scope.PlayerTop = res.data; 
      });
    }
  }

  if( $routeParams.arg == "user" ) {
    $http.get("https://riplay.fr/api/user/"+$routeParams.sub+"/stats").then(function(res) { 
      $scope.stats = res.data; 
    });

    $http.get("https://riplay.fr/api/live/connected/"+$routeParams.sub).then(function(res) { 
      $scope.connected = parseInt(res.data); 
    });

    $http.get("https://riplay.fr/api/user/job/"+$routeParams.sub).then(function(res) { 
      $scope.userJobs = res.data;
    })
  }
  $scope.dropCallback = function(event, index, item, external, type) {
    for(var i in $scope.data.notes ) {
      if( $scope.data.notes[i].id == item.id ) {
        
      }
    }
  };

  $scope.secondsToHours = function(seconds) {
    return Math.round(seconds*10/(60*60))/10;
  }

  $scope.getRank = function(pos, point) {
    if( pos == 1 ) return "Président";
    else if( pos >= 2 && pos < 4 ) return "Vice-Président";
    else if( pos >= 4 && pos < 8 ) return "Ministre";
    else if( pos >= 8 && pos < 14 ) return "Haut Conseiller";
    else if( pos >= 14 && pos < 22 ) return "Assistant-Haut Conseiller";
    else if( pos >= 22 && pos < 32 ) return "Conseiller";
    else if( pos >= 32 && pos < 46 ) return "Maire";
    else if( pos >= 46 && pos < 62 ) return "Porte-Parole";
    else if( pos >= 62 && pos < 80 ) return "Citoyen dévoué";
    else if( pos >= 80 && pos < 100 ) return "Citoyen";
    else if( point < 0 ) return "Rôdeur";
    else return "Visiteur";
  }
  $scope.UpdateData = function(id) {
    $http.put("https://riplay.fr/api/"+$routeParams.arg+"/"+$routeParams.sub+"/"+$scope.steamid, {id: id})
    .then(function (res) {
      $http.get("https://riplay.fr/api/"+$routeParams.arg+"s/"+$routeParams.sub+"/users").then(function(res) {
        //$scope.players = res;
        $scope.players = res.data;
      });
      $scope.showDialog = false;
    /*})
    .error(function (res) {*/
    },function (res){
      $scope.$parent.showAlert = true; 
      $scope.$parent.messageAlert = res.message; 
      $scope.$parent.messageTitle = "Erreur"; 
    });
  }
  $scope.UpdateNote = function(id) {

    $http.post("https://riplay.fr/api/"+$routeParams.arg+"/"+$routeParams.sub+"/note/"+id, {txt: $scope.laNote.name, hidden: 0})
    .then(function (res) {
      $http.get("https://riplay.fr/api/"+$routeParams.arg+"/"+$routeParams.sub).then(function(res) {  $scope.data = res;});
      $scope.editShowNote = false;
    /*})
    .error(function (res) {*/
    },function (res){
      $scope.$parent.showAlert = true; 
      $scope.$parent.messageAlert = res.message; 
      $scope.$parent.messageTitle = "Erreur"; 
    });
  }

  $scope.toggleModal = function(){ $scope.showDialog = !$scope.showDialog;};

  $scope.subParams = $routeParams.sub;
  $scope.routeArgs = $routeParams.arg;

  //console.log("routeparam" + $routeParams.sub);
});
app.controller('rpIndex', function($scope, $http, $timeout, $interval, $window, $location) {
  document.title = "Riplay | RolePlay";

  function setDay(dayOfWeek, hour, minutes) {
    var d = new Date();
    d.setDate(d.getDate() + (dayOfWeek + 7 - d.getDay()) % 7);
    d.setHours(hour);
    d.setMinutes(minutes);
    d.setSeconds(0);
    return d;
  }

  function dateDiff(date1, date2){
    var diff = {}  
    var tmp = Math.abs(date1 - date2);
    
    tmp = Math.floor(tmp/1000);  
    diff.sec = tmp % 60;    
 
    tmp = Math.floor((tmp-diff.sec)/60);
    diff.min = tmp % 60;               
 
    tmp = Math.floor((tmp-diff.min)/60);
    diff.hour = tmp % 24;   
     
    tmp = Math.floor((tmp-diff.hour)/24);
    diff.day = tmp;
     
    return diff;
}

  var wed = setDay(3, 18, 0);
  var sun = setDay(7, 21, 0);
  var now = new Date();
  $scope.pvp = ((now-sun)<(now-wed)?wed:sun);

  $http.get("https://riplay.fr/api/live/stats").then(function(res) {
    var delta = (res.data.time.h*60) + res.data.time.m + parseInt(((new Date())/1000) - res.data.time.t);
    $scope.stats = res.data;
    $scope.stats.time.h = parseInt(delta/60)%24;
    $scope.stats.time.m = (delta)%60;

    $interval( function() {
      delta += 1;
      $scope.stats.time.h = parseInt(delta/60)%24;
      $scope.stats.time.m = (delta)%60;
    }, 1000);
  });

  $http.get("https://riplay.fr/api/live/bf/5.196.39.50/27015").then(function(res) { 

    if(Date.now() > res.data.start_date * 1000 && Date.now() < res.data.end_date * 1000) {
      $scope.reduction = res.data.reduction;
      $scope.bf = true;
      $scope.end = res.data.end_date;
      $scope.calcEnd = dateDiff(now, $scope.end * 1000);

    
      $interval( function() {
        $scope.calcEnd = dateDiff(Date.now(), $scope.end * 1000);
      }, 1000);
    } else {
      $scope.bf = false;
      $scope.nextbf = res.data.start_date_f;
    }
    //
  });
});
app.controller('rpCraft', function($scope, $http, $routeParams, $timeout, $interval, $window, $location) {
  document.title = "Riplay.fr | RolePlay - Les crafts";

  $scope.rnd = Math.random();
  $scope.me = $routeParams.arg;
  $scope.$watch('me', function(newValue, old) {
    $location.path("craft/"+newValue);
  });

function lookup(data, id, name, desc, amount, size, parent) {
	var leaf = { id: id, name: name, desc: desc, amount: amount, width: size, height: size, children: [], parent: parent};
	data.map( k => {
		if( id == k.itemid ) {
			lookup(data, k.raw, k.nom, k.description, k.amount, size, leaf);
		}
	});

	if( parent )
		parent.children.push(leaf);

	return leaf;
}
function color(type) {
	switch(parseInt(type)) {
		case 1: return "#f33";
		case 2: return "#ff3";
		case 3: return "#3f3";
	}

	return "#333";
}
function getdesc(type, desc) {
        switch(parseInt(type)) {
                case 1: return "Cet objet nécéssite de posséder la spécialité <strong>Forgeron</strong>.";
                case 2: return "Cet objet nécéssite de posséder la spécialité <strong>Ingénieur</strong>.";
                case 3: return "Cet objet nécéssite de posséder la spécialité <strong>Alchimiste</strong>.";
        }

        return desc;
}
function render(r, dict) {
	const size = 40;
	const border = 4;
	const version = 2;
	const type = dict[r.id] ? dict[r.id].type : 0;

	const title = r.name;
	const desc = getdesc(type, r.desc).replaceAll("'", " ");
	const amount = r.parent ? (r.amount + "x") : "";

	var parent = $("<div data-toggle='popover' title='"+title+"' data-content='"+desc+"'><img src='/images/roleplay/csgo/craft/"+version+"/"+r.id+".png?v="+$scope.rnd+"' width='100%' height='100%' /><span>"+amount+"</span></div>").css({
		position: "absolute",
		top: r.y, left: r.x,
		width: r.width, height: r.height,
		border: "2px solid "+color(type)+"",
		outline: "1px solid black",
                backgroundColor: "#333"
	}).appendTo("#tree");

        if( r.children.length == 0 ) {
		$(parent).css({
			border: "2px solid white",
		});
	}
	else if( r.children.length == 1 ) {
		$("<div></div>").css({
			position: "absolute",
			top: r.y+r.height,
			left: r.x+(r.width/2)-border/2,
			height: size+2,
			width: border,
			border: "1px solid black",
			backgroundColor: ""+color(type)+""
		}).appendTo("#tree");
	}
	else if( r.children.length >= 1 ) {
		$("<div></div>").css({
			position: "absolute",
			top: r.y+r.height,
			left: r.x+(r.width/2)-border/2,
			height: size/2+1, width: border,
			border: "1px solid black",
			borderBottom: "0",
			backgroundColor: ""+color(type)+"",
			zIndex: 2
		}).appendTo("#tree");

                var p, q;
		var m = null;
		r.children.map(c => {
			$("<div></div>").css({
				position: "absolute",
				top: c.y - size/2 + border - 1,
				left: c.x+(c.width/2)-border/2,
				height: size/2 - border + 1, width: border,
				border: "1px solid black",
				borderTop: "0",
				zIndex: 2,
				backgroundColor: ""+color(type)+"",
			}).appendTo("#tree");


			[p, q] = (c.x < r.x) ? [c, r] : [r, c];
			var n = $("<div></div>").css({
				position: "absolute",
				top: r.y+r.height+size/2,
				left: p.x+(p.width/2)-border/2,
				height: border,
				width: (q.x+(q.width/2)) - (p.x+(p.width/2))+border,
				borderTop: "1px solid black",
				borderBottom: "1px solid black",
				borderRight: "1px solid black",
				backgroundColor: ""+color(type)+""
			}).appendTo("#tree");

			if( !m ) {
				m = n;
			}
		});
		$(m).css({ borderLeft: "1px solid black" });
	}

	r.children.map( m => render(m, dict));
}

  $http.get("https://riplay.fr/api/items/craft/0").then(function(res) {
    $scope.craft = res.data;

    if( $scope.me != 0 ) {
      $http.get("https://riplay.fr/api/items/craft/" + $scope.me).then(function(res) {
        const data = res.data;
        const item = $scope.craft.filter( i => i.id == $scope.me )[0];

        const treeData = lookup(data, $routeParams.arg, item.nom, item.description, 1, 50);
        let dict = {};
        data.map( k => dict[k.raw] = { name: k.nom, type: k.extra_cmd.split(" ")[1] });

        const layout = new nonLayeredTidyTreeLayout.Layout(new nonLayeredTidyTreeLayout.BoundingBox(20, 40));
        const { result, boundingBox } = layout.layout(treeData);
        $("#tree").html("");
        render(result, dict);
      });
    }
  });

});
app.controller('rpMap', function($scope, $http, $routeParams, $timeout, $interval, $window, $location) {

  document.title = "Riplay.fr | RolePlay - La carte";

  var element = document.getElementById('heatmap');
  var heatmapInstance;
  $scope.timer = null;
  $scope.multiX = 13.0;
  $scope.multiY = -13.0;
  $scope.deltaX = 726;
  $scope.deltaY = 349;

  function scaleX(x, scale) { return Math.floor(((x/$scope.multiX)+$scope.deltaX)*scale); }
  function scaleY(y, scale) { return Math.floor(((y/$scope.multiY)+$scope.deltaY)*scale); }
  $scope.$watchGroup(['multiX', 'multiY', 'deltaX', 'deltaY'], function(newValue, oldValue, scope) {
    $scope.maparea();
  });

  $scope.$on("$destroy", function() {
      if ($scope.timer) { $timeout.cancel($scope.timer); }
  });

  $http.get("https://riplay.fr/api/zones").then(function(res) {
    $scope.mapData = JSON.parse(lzw_decode(res.data));
    $scope.maparea();
    angular.element($window).bind('resize', function () { $scope.maparea(); });
  });
  $http.get("https://riplay.fr/api/live/stats").then(function(res) {
    var delta = (res.data.time.h*60) + res.data.time.m + parseInt(((new Date())/1000) - res.data.time.t);
    $scope.stats = res.data;
    $scope.stats.time.h = parseInt(delta/60)%24;
    $scope.stats.time.m = (delta)%60;

    $interval( function() {
      delta += 1;
      $scope.stats.time.h = parseInt(delta/60)%24;
      $scope.stats.time.m = (delta)%60;
    }, 1000);
  });

  $scope.maparea = function() {
    $(element).find("map").find("area").remove();

    var res = $scope.mapData;
    var scale = (1/1200 * $(element).outerWidth());

    for(var i=0; i<res.length; i++) {
      var href = '';
      if( !isNaN( parseInt(res[i].type) ) )
        href = "href='#/job/"+res[i].type+"?TABS=player'";

      var coords = scaleX(res[i].min[0], scale)+","+scaleY(res[i].min[1], scale);
      coords += ","+scaleX(res[i].max[0], scale)+","+scaleY(res[i].min[1], scale);
      coords += ","+scaleX(res[i].max[0], scale)+","+scaleY(res[i].max[1], scale);
      coords += ","+scaleX(res[i].min[0], scale)+","+scaleY(res[i].max[1], scale);

      var area = '<area share="poly" coords="'+coords+'" '+href+' data-title="'+res[i].owner+'" data-msg="'+res[i].name+'" data-pv="'+res[i].private+'">';

      $(element).find("map").append(area);
    }
  }
  $scope.heatmapStop = function() {
    $(element).find("canvas").css({"z-index": "-1"});
    $timeout.cancel($scope.timer);
    $scope.timer = null;
  }
  $scope.heatmap = function() {
    $(element).find("canvas").css({"z-index": "1"});
    $http.get("https://riplay.fr/api/live/positions").then(function(res) {
      var points = heatmapInstance.getData().data;
      var nP = new Array();
      for( var i=0; i<points.length; i++) {
        if( points[i].value > 3 )
          points[i].value = 3;
        points[i].value--;
        if( points[i].value > 0 )
          nP.push(points[i]);
      }

      var scale = (1/1200 * $(element).outerWidth());
      $scope.connected = res.data.length;
      $scope.lastUpdate = new Date();

      for(var i=0; i<res.data.length; i++) {
        nP.push({ x: scaleX(res.data[i][0], scale), y: scaleY(res.data[i][1], scale), value: 3});
      }
      heatmapInstance.setData({min: 1, max: 4, data: nP});
      $scope.timer = $timeout( function() { $scope.heatmap(); }, 100);
    });
  }
  $(element).find("img").bind('load', function() {
    heatmapInstance = h337.create({container: element, radius:25});
  });
  $(element).find("map").on("mouseover", "area", function() {
    var cvs = document.createElement("a");
    var mCoords = $(this).attr("coords").split(',');
    var pos = $(this).offset();

    if( $("#uniquePopUp").length > 0 ) {
      $("#uniquePopUp").popover('destroy');
      $("#uniquePopUp").remove();
    }

    cvs.id = "uniquePopUp";
    cvs.style.position = "absolute";
    cvs.style.top = parseInt(mCoords[5])+pos.top+"px";
    cvs.style.left = parseInt(mCoords[0])+pos.left+"px";
    cvs.style.zIndex = "9999";
    if( $(this).attr("data-pv") == "1" ) {
      cvs.style.border = "1px solid red";
      cvs.style.backgroundColor = "rgba(255, 0, 0, 0.25)";
    }
    else {
      cvs.style.border = "1px solid green";
      cvs.style.backgroundColor = "rgba(0, 255, 0, 0.25)";
    }
    cvs.style.width = (parseInt(mCoords[2])-parseInt(mCoords[0]))+"px";
    cvs.style.height = (parseInt(mCoords[3])-parseInt(mCoords[5]))+"px";
    cvs.setAttribute("data-toggle", "popover");
    cvs.setAttribute("data-content", $(this).attr("data-msg"));
    cvs.setAttribute("data-original-title", $(this).attr("data-title"));

    if( $(this).attr("href") )
      cvs.href = $(this).attr("href");
    else if( $(this).attr("data-pv") == "1" )
      cvs.setAttribute("data-original-title", "Zone privée");
    else
      cvs.setAttribute("data-original-title", "Tout publique");

    $(cvs).mouseleave( function() { $(this).popover('destroy'); $(this).remove();	});
    $(cvs).click( function() { $(this).popover('destroy'); $(this).remove();	});
    document.body.appendChild(cvs);
  });
});
app.controller('rpSearch', function($scope, $http, $location) {
  $scope.search = "";
  $scope.data = [];

  if( $location.search() !== undefined) {
    $scope.search = Object.keys($location.search())[0];
  }
  $scope.sendSearch = function(param) {
    $http.get("https://riplay.fr/api/user/search/"+$scope.search).then(function(res) { 
      if( param == $scope.searchLast ) {
        $scope.data = res.data; 
      }
    },function (error){
      $scope.data = []; 
    });
    /*}).error(function() { 
      $scope.data = []; 
    });*/
  }

  $scope.updateSteamID = function() {
    if( $scope.search === undefined || $scope.search.length <= 1 )
      return;

    $location.search($scope.search);
    $scope.searchLast = Math.random();
    $scope.sendSearch($scope.searchLast);

  }


  $scope.updateSteamID();
});
app.controller('rpTribunal', function($scope, $location, $filter, $http, $routeParams) {
  document.title = "Riplay.fr | RolePlay - Le Tribunal";

  if( $routeParams.arg == "rules" ) {
    $http.get("https://riplay.fr/api/tribunal/next").then(function(res) { $scope.report = res.data; });
  }
  else if( $routeParams.arg == "last" ) {
    $http.get("https://riplay.fr/api/tribunal/last").then(function(res) { $scope.report = res.data; });
  }
  else if( $routeParams.arg == "mine" ) {
    $scope.update = function(item) {
      $location.path("/tribunal/phone/"+item);
    }
    $scope.getTitleName = function( item ) {
        var ret = item.title + " du "+ $filter('date')( new Date(item.timestamp*1000), 'dd/MM à HH:mm');
        if( item.seen == 0 ) ret += ' - NOUVEAU MESSAGE';
        return ret;
    }
    $http.get("https://riplay.fr/api/tribunal/mine").then(function(res) { 
      $scope.reportTribu = res.data; 
    });
    $http.get("https://riplay.fr/api/report").then(function (res) { $scope.reportPolice = res.data; });
  }
  else if( $routeParams.arg == "report" ) {
    document.title = "Riplay.fr | RolePlay - Rapporter un joueur";
    $scope.steamid = '';
    if( $location.search() !== undefined) {
      $scope.steamid = Object.keys($location.search())[0];
      //console.log($scope.steamid);
    }

    $scope.nowDate = $filter('date')(new Date(), "le d/M à HH:mm");
    $scope.reasonT=['Insultes, Irrespect, Menace', 'Vol', 'Meurtre', 'Freekill massif', 'Autre, préciser:' ];
    $scope.reasonCT=['Jail dans une propriétée privée', 'Abus de /jail', 'Jail par déduction', 'Freekill en fonction', 'Abus de perquisition', 'Autre, préciser:' ];
    $scope.reason = $scope.reasonT;
    $scope.typePolice = 0;

    $scope.$watch('pData', function(newValue, old) {
      if( newValue.job_id>=1&&newValue.job_id<=9||newValue.job_id>=101&&newValue.job_id<=109 ) {
        $scope.typePolice = '1';
        $scope.reason = $scope.reasonCT;
      }
      else {
        $scope.typePolice = '0';
        $scope.reason = $scope.reasonT;
      }
    });
    $scope.report = function() {
      var search = new RegExp(/^le ([0-9]{1,2})\/([0-9]{1,2}) à ([0-9]{1,2}):([0-9]{1,2})$/);
      var buffer = search.exec($scope.nowDate);
      var date = new Date( (new Date()).getFullYear(), parseInt(buffer[2])-1, parseInt(buffer[1]), parseInt(buffer[3]), parseInt(buffer[4]), 0, 0);
      var type = parseInt($scope.typePolice);
      var obj = {steamid: $scope.steamid, timestamp: date, reason: ($scope.rType2.length>1?$scope.rType2:$scope.rType), moreinfo: $scope.moreInfo};

      if( type === 1 ) {
        $http.post("https://riplay.fr/api/report/police", obj).then(function (response) {
          $scope.$parent.showAlert = true;
          $scope.$parent.messageAlert = "Votre rapport a été envoyé, il va maintenant être lu par des référés. Ce sont des personnes n'étant ni policier, ni admin.";
          $scope.$parent.messageTitle = "Envois d'un rapport: Ok!";
          if( response !== undefined )
            $location.path("/tribunal/phone/"+response.data.id);
        });
      }
      else {
        $http.post("https://riplay.fr/api/report/tribunal", obj).then(function (response) {
          $scope.$parent.showAlert = true;
          $scope.$parent.messageAlert = "Votre rapport a été envoyé, il va maintenant être traité par le conseil des no-pyjs, puis par les hauts-juges.";
          $scope.$parent.messageTitle = "Envois d'un rapport: Ok!";
          if( response !== undefined )
            $location.path("/tribunal/case/"+response.data.id);
        });
      }
    }
  }
});
app.controller('rpPiloriCase', function($scope, $location, $filter, $http, $routeParams) {
  document.title = "Riplay.fr | RolePlay - Le Pilori";
  var id = $routeParams.sub;
  $scope.steamid = _steamid;

  $scope.getBanDuration = function(reason, time) {
    var duration = new Array();

    switch(reason) {
      case "irrespect":
      case "spam": duration = [-5, -15, -60, 15, 60, 24*60, 2*24*60, 5*24*60, 7*24*60, 14*24*60, 21*24*60, 31*24*60, 40*24*60, 60*24*60, 90*24*60, 120*24*60]; break;
      case "event": duration = [60, 24*60, 2*24*60, 5*24*60, 7*24*60, 14*24*60, 31*24*60]; break;
      case "usebug": duration = [7*24*60, 365*24*60]; break;
      case "cheat": duration = [365*24*60]; break;
      case "double": duration = [0]; break;
      case "refus": duration = [60, 24*60, 2*24*60, 5*24*60, 7*24*60, 14*24*60, 31*24*60]; break;
      default: duration = [60, 24*60, 2*24*60, 5*24*60, 7*24*60, 14*24*60, 31*24*60]; break;
    }

    if( duration.length <= time )
      time = duration.length - 1;
    return duration[time];
  }

  if( $routeParams.arg == "view" ) {
    $http.get("https://riplay.fr/api/user/pilori/"+id).then(function (response) {
      $scope.data = response.data;
      var j = 0;
      for(var i=0; i<response.data.length; i++) if( response.data[i].banned == 1 ) j++;
      $scope.banned = j;
    });
    $http.get("https://riplay.fr/api/user/pilori/"+id+"/next").then(function (response) { 
      $scope.next = response.data; 
    });
  }
  if( $routeParams.arg == "double" ) {
    $scope.paramsSub = $routeParams.sub;

    $http.get("https://riplay.fr/api/user/double/steamid/"+id).then(function (response) {
      $scope.data = response.data;
      $scope.fullData = new Array();

      angular.forEach(response.data, function(key) {
        $http.get("https://riplay.fr/api/user/"+key).then(function (response2) {
          $scope.fullData[key] = response2.data;
        });
      });

    });
  }
  if( $routeParams.arg == "last" ) {
    $scope.paramsSub = $routeParams.sub;
    $http.get("https://riplay.fr/api/user/pilori/last/"+id).then(function (response) {
     $scope.data = response.data; 
   });
  }

});
app.controller('rpTribunalCase', function($scope, $location, $routeParams, $http, $timeout, $filter) {
  document.title = "Riplay.fr | RolePlay - Tribunal - Gestion d'un cas";
  $scope.case = $routeParams.sub;

  if( $routeParams.arg == "phone" ) {
    var id = $routeParams.sub;
    $http.get("https://riplay.fr/api/user/"+$scope.steamid).then(function (response) { 
      //$scope.me = response; 
      $scope.me = response.data;
    });
    $http.get("https://riplay.fr/api/report").then(function (response) { 
      //$scope.reports = response; 
      $scope.reports = response.data;
    });
    $http.get("https://riplay.fr/api/report/"+id).then(function (response) { 
      //$scope.plainte = response[0]; 
      $scope.plainte = response.data[0]; 
    });
    $http.get("https://riplay.fr/api/report/"+id+"/response").then(function (response) { 
      //$scope.response = response;
      $scope.response = response.data;
    });
    $http.get("https://riplay.fr/api/report/"+id+"/log").then(function (response) { 
      //$scope.logs = response; 
       $scope.logs = response.data; 
    });

    $scope.lock = function() {
      $http.put("https://riplay.fr/api/report/"+id, {lock: 1}).then(function (response) { });
    }
    $scope.reply = function() {
			$scope.rapportReply = $scope.rapportReply.trim();
			if( $scope.rapportReply == "" ) return;

      var tmp = $scope.rapportReply;
			$http.post("https://riplay.fr/api/report/"+id+"/reply", {text: $scope.rapportReply}).then(function (response) {
				$scope.response.unshift({name: $scope.me.name, steamid: $scope.steamid, text: tmp});
			});
      $scope.rapportReply = "";
		}
    $scope.update = function(item) {
      $location.path("/tribunal/phone/"+item);
    }
    $scope.getTitleName = function( item ) {
        var ret = item.title + " du "+ $filter('date')( new Date(item.timestamp*1000), 'dd/MM à HH:mm');
        if( item.seen == 0 ) ret += ' - NOUVEAU MESSAGE';
        return ret;
    }
  }
  else if( $routeParams.arg == "case" ) {
    $scope.steamid='';
    $scope.playtime = {}; 
    $scope.tribunal = {}; 
    $scope.ratio = {};
    $scope.disableButton = true;

    $http.get("https://riplay.fr/api/tribunal/"+$scope.case).then(function(res) {
      $scope.steamid = res.data.steamid;
      $scope.moreinfo = res.data.data;
      $scope.condamner = parseInt(res.data.condamner);
      $scope.acquitter = parseInt(res.data.acquitter);

      $http.get("https://riplay.fr/api/tribunal/next").then(function(res) { $scope.report = res.data; });

      $timeout(function() { $scope.disableButton = false; }, 5000);

      $http.get("https://riplay.fr/api/user/"+$scope.steamid).then(function(res) { 
        $scope.data = res.data; 
      });
      $http.get("https://riplay.fr/api/live/connected/"+$scope.steamid).then(function(res) { 
        $scope.connected = parseInt(res.data); 
      });

      angular.forEach(["31days", "month", "begin", "start"], function(key) {
        $http.get("https://riplay.fr/api/user/"+$scope.steamid+"/playtime/"+key).then(function(res) { 
          $scope.playtime[key] = res.data; 
        });
      });
      angular.forEach(["31days", "month", "begin"], function(key) {
        $http.get("https://riplay.fr/api/user/"+$scope.steamid+"/ratio/"+key).then(function(res) { 
          $scope.ratio[key] = res.data; 
        });
      });
      angular.forEach($scope.cat, function(val, key) {
        $http.get("https://riplay.fr/api/tribunal/"+$scope.case+"/"+key).then(function(res) { 
          $scope.tribunal[key] = res.data; 
        });
      });
    });

    $scope.cat = {chat: "Chat", money: "Transaction", kill: "Meurtre", jail: "Prison", item: "Item", buy: "Vente", steal: "Vol", connect: "Connexion", other: "Autres" };

  }
});
app.controller('rpSteamIDLookup', function($scope, $http) {

  $scope.$watch('steamid', function(newValue, oldValue) {
    SteamIDLookup(newValue);
  });

  function SteamIDLookup(steamid) {
    //var pattern = /^STEAM_[01]:[01]:[0-9]{1,18}$/g;
    var pattern = /^[0-9]{17}$/g;
    
    if( pattern.test($scope.steamid) ) {
      steamid = steamid.replace("STEAM_0", "STEAM_1").trim();
      $http.get("https://riplay.fr/api/user/"+steamid)
        .then(function(res) { 
          //$scope.$parent.pData = res; 
          $scope.$parent.pData = res.data; 
          $scope.$parent.valid = true; 
        /*})
        .error(function() {*/
        },function (error){
          $scope.$parent.pData.name = "ERREUR: SteamID non trouvé"; $scope.$parent.valid = false;
      });
    }
    else {
      $scope.$parent.valid = false;
      //$scope.$parent.pData.name = "ERREUR: SteamID non valide";
    }
  }

});
app.controller('rpHDV', function($scope, $http, $routeParams, $location) {
  document.title = "Riplay.fr | RolePlay - Hôtel des ventes";
  $scope.monFiltre = '';
  $http.get("https://riplay.fr/api/hdv/sales/"+$routeParams.arg).then(function(res) { $scope.HDV = res.data;});
});
app.controller('rpGraph', function($scope, $routeParams, $location, $http) {
  document.title = "Riplay.fr | RolePlay - Graphique des jobs";
  
  $http.get("https://riplay.fr/api/jobs").then(function(res) { 
    $scope.jobs = res.data; 
  });

  $scope.me = $routeParams.sub;
  $scope.url = "https://riplay.fr/api/best/job";

  if( $routeParams.sub != 0 && $routeParams.sub != 'null' && $routeParams.sub != 'undefined' )
    $scope.url = "https://riplay.fr/api/best/job/"+$routeParams.sub;

  $scope.$watch('me', function(newValue, old) {
    $location.path("graph/"+newValue);
  });
});

app.controller('rpTest', function($scope, $http, $routeParams, $location) {
  document.title = "Riplay.fr | RolePlay - TEST KRIAX";
  $scope.monFiltre = '';
});

app.controller('rpDonation', function($scope, $http, $routeParams, $location) {
  document.title = "Riplay.fr | RolePlay - Donation";
  $scope.ppAmount = 20;
  $scope.ppReward = function(amount) {
      var ratio = 0;
      var cadeau = 2;

      if( amount < 5 )       { ratio = 5000; }
      else if( amount < 10 ) { ratio = 6000; }
      else if( amount < 20 ) { ratio = 7000; }
      else if( amount < 30 ) { ratio = 8000; }
      else if( amount < 40 ) { ratio = 9000; }
      else if( amount < 50 ) { ratio = 10000; }
      else                   { ratio = 20000; }

      var paypalFee = 0.35;
      var paypalComi = 0.034;

      var serv = (amount*(1-paypalComi))-paypalFee;

      return { amount: Math.round(serv*ratio), cadeau: Math.round(amount*2), xp: Math.round(serv*ratio*0.1) };
  }

  $http.get("https://riplay.fr/api/rank/donate").then(function(res) { 
    var data = [];
    var pos = 0;

    res.data.rank.forEach( item => {
      pos++;

      data.push({
        steamid: item.steamid,
        name: item.name,
        pos: pos
      });
    });

    $scope.data = data;
    $scope.needed = res.data.needed;
  });
});

app.controller('rpParrainage', function($scope, $http, $routeParams, $location) {
  document.title = "Riplay.fr | RolePlay - Parrainage";
  
  if(_steamid == null || _steamid == undefined || !_steamid) {
    $window.location.href = 'http://rpweb.riplay.fr';
  }

  $http.get("https://riplay.fr/api/parrain").then(function(res) { 
    var data = [];
    var pos = 0;
    var need_time = 72000;

    res.data.forEach( item => {
      data.push({
        approuved: item.approuved,
        name: item.name,
        steamid: item.steamid,
        played: item.played,
        canvalidate: item.played >= need_time ? true:false,
        progress: ((item.played / need_time) * 100).toFixed(2)
      });
    });

    $scope.need_time = need_time;
    $scope.data = data;
  });

  $scope.validate = function(steamid) {
    $http.post("https://riplay.fr/api/parrain/"+steamid+"/validate") .then(function (res) {
      
      $scope.editShowNote = false;

      let index = $scope.data.findIndex(element => element.steamid == steamid);
      $scope.data[index].approuved = 1;

      $scope.data = $scope.data;
    },function (res){
      $scope.errmessage = "Error";
    });
  }
});

app.controller('rpSuccess', function($scope, $http, $timeout, $interval, $window, $location, $routeParams) {
  document.title = "Riplay RolePlay - Success";
  $scope.steamid = $routeParams.sub;

  $http.get("https://riplay.fr/api/user/"+$scope.steamid).then(function(res) { 
    $scope.user = res.data;
    $scope.isValidUser = true;

    $http.get("https://riplay.fr/api/user/" + $scope.steamid + "/success").then(function(res) {
      $scope.successList = res.data;

      var list = [];
      var success = [];

      $scope.successList.forEach(i => {
        if(i != null && i.id != 'unknown') {
         list.push(i);

         i.last_achieved = i.last_achieved == null || i.last_achieved <= 0 ? 0:i.last_achieved*1000;
         i.progress = ((i.count_to_unlock / i.need_to_unlock) * 100).toFixed(2);
        }
      });

      //list.sort(sorting('progress', 'desc'));
      //list.sort(sorting('achieved', 'desc'));

      $scope.list = list;
    });
  }
  ,function (res){
      $scope.isValidUser = false;

      $http.get("https://riplay.fr/api/success").then(function(res) {
      $scope.successList = res.data;

      var list = [];
      var success = [];

      $scope.successList.forEach(i => {
        if(i != null) {
         list.push(i);
        }
      });

      $scope.list = list;
    });
  });
});

function sorting(key, order = 'asc') {
  return function innerSort(a, b) {
    if (!a.hasOwnProperty(key) || !b.hasOwnProperty(key)) {
      return 0;
    }

    const varA = (typeof a[key] === 'string') ? a[key].toUpperCase() : a[key];
    const varB = (typeof b[key] === 'string') ? b[key].toUpperCase() : b[key];

    if (varA > varB) {
      return (order === 'desc') ? (1 * -1) : 1
    } else if (varA < varB) {
      return (order === 'desc') ? (-1 * -1) : -1
    }
  }
};

function lzw_decode(s) {
  var dict = {};
  var data = (s + "").split("");
  var currChar = data[0];
  var oldPhrase = currChar;
  var out = [currChar];
  var code = 256;
  var phrase;
  for (var i=1; i<data.length; i++) {
      var currCode = data[i].charCodeAt(0);
      if (currCode < 256) {
          phrase = data[i];
      }
      else {
         phrase = dict[currCode] ? dict[currCode] : (oldPhrase + currChar);
      }
      out.push(phrase);
      currChar = phrase.charAt(0);
      dict[code] = oldPhrase + currChar;
      code++;
      oldPhrase = phrase;
  }
  return out.join("");
}

};
