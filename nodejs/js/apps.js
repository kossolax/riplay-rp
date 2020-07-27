// sssss
require("./angular/ctrl/roleplay.js")(app);
require("./angular/route/roleplay.js")(app);
require("./angular/directive/roleplay.js")(app);
require("./angular/filter/roleplay.js")(app);

app.controller("lights", function($scope, $window, $http, $interval) {
	$scope.bulb = new Array();
	for(var i=0; i < Math.floor($window.innerWidth / 32) - 1; i++) {
		$scope.bulb.push( {id: i, color: Math.floor(Math.random()*4) , state: Math.floor(Math.random()*2)} );
	}

	$scope.colors = ["#19f", "#aaa", "#f22", "#080"];

	$interval(function() {
		for(var i=0; i < $scope.bulb.length; i++) {
			if( Math.random() < 0.1 && $scope.bulb[i].state != 2 )
				$scope.bulb[i].state = Math.floor(Math.random()*2);
		}
	}, 100);

	$scope.explode = function(i) {
		if( $scope.bulb[i].state != 2 ) {
			$scope.bulb[i].state = 2;

			var audio = new Audio('/sound/glass'+Math.floor(Math.random()*5)+'.mp3');
			audio.volume = 0.01;
			audio.play();

			$http.put("/api/forum/bulb");

			for(var j=0; j<4; j++)
				$scope.particles(i);
		}
	}

	$scope.particles = function(i) {
		var html = document.createElement("span");

		html.innerHTML = "&bull;";
		html.className = "bulblette";
		html.style.color = $scope.colors[$scope.bulb[i].color];
		html.style.left = 32*i + Math.floor(Math.random()*32) + "px";
		html.style.bottom = Math.floor(Math.random()*10) + "px";

		document.body.appendChild(html);

		var promise = $interval(function() {
			var px = parseInt(html.style.bottom);
			html.style.bottom = px - 2 +"px";

			if( px < -16 ) {
				document.body.removeChild(html);
				$interval.cancel(promise);
			}
		}, 20);

	}
});
