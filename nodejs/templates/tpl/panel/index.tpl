<script src="/js/socket.io-1.3.5.js"></script>
<script type="text/javascript">
	var app = angular.module('tsx', []);
	app.controller('ctrlPanel', function($scope, $http, $filter) {
		$http.defaults.headers.common['auth'] = _md5;

		$scope.log = new Array();
		$scope.serv = { ip: '178.32.42.113', port: 27015, name: "CSGO-RP"};
		$scope.Math = window.Math;
		$scope.load = $scope.cpu = $scope.mem = $scope.players = 0;
		var selection = [];

		{noparse}
		$scope.filtres = [
				[ 'kill', new RegExp("\".*<([0-9]{1,5})><STEAM_1:[0-1]:[0-9]{1,14}><(TERRORIST|CT|)>.* killed .*<([0-9]{1,5})><STEAM_1:[0-1]:[0-9]{1,14}><(TERRORIST|CT|)>.* with .*\"|.*<([0-9]{1,5})><STEAM_1:[0-1]:[0-9]{1,14}><(TERRORIST|CT|)>\" assisted killing .*<([0-9]{1,5})><STEAM_1:[0-1]:[0-9]{1,14}><(TERRORIST|CT|)>.|.*<([0-9]{1,5})><STEAM_1:[0-1]:[0-9]{1,14}><(TERRORIST|CT|)>. .* committed suicide with \".*\"", "g") ],
				[ 'item', new RegExp(".*\\[TSX-RP\\] \\[ITEM\\] .*<[0-9]{1,5}><STEAM_1:[0-1]:[0-9]{1,14}><> a utilisé: ", "g") ],
				[ 'connect' , new RegExp(".*<[0-9]{1,5}><STEAM_1:[0-1]:[0-9]{1,14}><.*>\" entered the game|.*<[0-9]{1,5}><STEAM_1:[0-1]:[0-9]{1,14}><.*>\" triggered \"clantag\" \\(value \".*\"\\)|.*<[0-9]{1,5}><STEAM_1:[0-1]:[0-9]{1,14}><.*>\" connected, address \".*\"|.*<[0-9]{1,5}><STEAM_1:[0-1]:[0-9]{1,14}><.*>\" STEAM USERID validated|.*<[0-9]{1,5}><STEAM_1:[0-1]:[0-9]{1,14}><.*>\" disconnected \\(reason \".*\"\\)|.*<[0-9]{1,5}><STEAM_1:[0-1]:[0-9]{1,14}>\" switched from team <Unassigned> to <.*>|.*<[0-9]{1,5}><STEAM_1:[0-1]:[0-9]{1,14}>\" switched from team <.*> to <Unassigned>", "g")],
				[ 'say', new RegExp("\".*<([0-9]{1,5})><STEAM_1:[0-1]:[0-9]{1,14}><(TERRORIST|CT|)>.* say \".*\"|\\[TSX-RP\\] \\[CHAT-LOCAL\\] .*<([0-9]{1,5})><STEAM_1:[0-1]:[0-9]{1,14}><>: |\\[TSX-RP\\] \\[ANNONCES\\] .*<([0-9]{1,5})><STEAM_1:[0-1]:[0-9]{1,14}><>: ", "g") ],
				[ 'tsx-rp', new RegExp(".*\\[TSX-RP\\] \\[.*\\].*", "g")],
				[ 'admmin', new RegExp(".*\\[ADMIN-LOG\\] \\[cmd\\].*|.*\\[REMOVED\\].*<([0-9]{1,5})><STEAM_1:[0-1]:[0-9]{1,14}>.*", "g")]
		];
		{/noparse}

		$scope.updateSys = function(response) {
			$scope.load = response.loadavg; $scope.cpu = response.CPU; $scope.mem = response.memory; $scope.players = response.players;
			$scope.net = response.network / (10*1024) * 100.0;

			setTimeout(function() { $http.get("https://www.ts-x.eu/api/panel/sys").success($scope.updateSys); }, 1000);
		}
		$scope.updateServ = function(response) {
			$scope.servers = response;

			setTimeout(function() { $http.get("https://www.ts-x.eu/api/panel/servers").success($scope.updateServ); }, 5000);
		}
		$scope.toggle = function toggleSelection(name) {
			var idx = selection.indexOf(name);
			if (idx > -1)	selection.splice(idx, 1);
			else	selection.push(name);
		};
		$scope.submitItem = function() {
			var pattern = /^STEAM_[01]:[01]:[0-9]{1,18}$/g;
	    if( pattern.test($scope.steam) && $scope.amount != 0 && $scope.itemID > 0 ) {
	      $scope.steam = $scope.steam.replace("STEAM_0", "STEAM_1").trim();
				var obj = { itemid: $scope.itemID, amount: $scope.amount };
				$scope.amount = 0;
				$scope.itemID = 0;
				$http.post("https://www.ts-x.eu/api/user/"+$scope.steam+"/giveitem", obj).success(function(res) { window.alert(res); });
			}
		}
		$scope.submitMoney = function() {
			var pattern = /^STEAM_[01]:[01]:[0-9]{1,18}$/g;
	    if( pattern.test($scope.steam) || $scope.steam == 'CAPITAL' ) {
	      $scope.steam = $scope.steam.replace("STEAM_0", "STEAM_1").trim();
				if( $scope.steam == 'CAPITAL' && $scope.jobID <= -1 )
					return;
				var obj = { jobid: $scope.jobID, amount: $scope.amount };
				$scope.amount = 0;
				$scope.itemID = 0;
				$http.post("https://www.ts-x.eu/api/user/"+$scope.steam+"/givemoney", obj).success(function(res) { window.alert(res); });
			}
		}
		$scope.submitXP = function() {
			var pattern = /^STEAM_[01]:[01]:[0-9]{1,18}$/g;
	    if( pattern.test($scope.steam) ) {
	      $scope.steam = $scope.steam.replace("STEAM_0", "STEAM_1").trim();
				var obj = {amount: $scope.amount};
				$scope.amount = 0;
				$scope.itemID = 0;
				$http.post("https://www.ts-x.eu/api/user/"+$scope.steam+"/givexp", obj).success(function(res) { window.alert(res); });
			}
		}
		$scope.submitOrtho = function() {
			var obj = {typedText: $scope.text, isAjax: true};

			$http.post("http://bonpatron.com/ajax", obj).success(function(res) { window.alert(res); });
		}
		$scope.submitSocial = function() {
			if( $scope.text.length <= 1 )
				return;

			var obj = {txt: $scope.text, title: $scope.titre, url: $scope.url};

			$scope.text = "";
			$scope.titre = "";
			$scope.url = "";


			$http.post("https://www.ts-x.eu/api/panel/social", obj).success(function(res) { window.alert(res); });
		}

		$scope.amount = 0;
		$scope.itemsFiltred = [];
		$scope.$watch('monFiltre', function(val) {
			$scope.itemsFiltred = [];
			for(var i in $scope.items ) {
				if( $scope.items[i].nom.toLowerCase().indexOf(val.toLowerCase()) >= 0 ) {
					$scope.itemsFiltred.push($scope.items[i]);
				}
			}
		});

		$http.get("https://www.ts-x.eu/api/panel/sys").success($scope.updateSys);
		$http.get("https://www.ts-x.eu/api/panel/servers").success($scope.updateServ);
		$http.get("https://www.ts-x.eu/api/panel/email").success(function(res) { $scope.email = res; });
		$http.get("https://www.ts-x.eu/api/items").success(function(res) { $scope.items = res; });
		$http.get("https://www.ts-x.eu/api/jobs").success(function(res) { $scope.jobs = res; $scope.jobs.unshift({id: 0, name: "Sans emploi"}); $scope.jobs.unshift({id: -1, name: "Ne pas toucher"}); $scope.jobID = -1;});


		var socket = io('https://www.ts-x.eu:4433');
		socket.on('connect', function (data) {
			$scope.log.push("Log-in to "+$scope.serv.ip+":"+$scope.serv.port);
			socket.emit('auth', {sso: _md5, ip: $scope.serv.ip, port: $scope.serv.port});
		});
		socket.on('data', function (data) {
			for( var regex in selection ) {	if( data.match(selection[regex]) ) { return; } }
			if( $scope.log.length >= 30 ) $scope.log.shift();
			$scope.log.push(data);
		});


		$scope.$watch("serv.name", function(newVal, oldVal) {
			socket.disconnect();
			socket.connect();
		});

	});
</script>
<style type="text/css">
.gauges {
	display:table;
	width:auto;
	margin:auto;
}
.gauge {
  width: 200px;
  height: 100px;
	border-bottom: 1px solid white;
	position: relative;
  overflow: hidden;
	float: left;
}
.gauge-a {
  position: absolute;
  background-color: rgba(255,255,255,.2);
  width: 200px;
  height: 100px;
  border-radius: 125px 125px 0px 0px;
}
.gauge-b {
  position: absolute;
  background: linear-gradient(90deg, green, yellow, red);
  width: 200px;
  height: 100px;
  top: 100px;
  border-radius: 0px 0px 100px 100px;
  transform-origin: center top;
  transition: all 1s ease-in-out;
}
.gauge-c {
  position: absolute;
  background-color: #222;
  width: 125px;
  height: 62px;
  top: 38px;
  margin-left: 38px;
  border-radius: 125px 125px 0px 0px;
}
.gauge-d {
  position: absolute;
  top: 55px;
  width: 200px;
  height: 100px;
	font-size: 20px;
	line-height: 20px;
	text-align: center;
}
.tab-content {
	height: 550px;
}
textarea {
	resize: vertical;
}
</style>
<div class="row" ng-controller="ctrlPanel">
	<h2 class="col-sm-offset-2 col-sm-10">Gestion des serveurs</h2>
	<div class="col-sm-12">
		<div class="col-sm-2">
			<ul class="list-unstyled">
			  <li>
					<h3>Gestion serveur</h3>
					<ul class="list-unstyled">
						<li ng-repeat="item in servers">
							<a href="#" ng-class="(item.is_on?'text-success':'text-warning')" ng-click="serv.ip = item.ip; serv.port = item.port; serv.name = item.uniq_id;">
								<img src="/images/icons/section/{{item.game}}.png" /> {{item.uniq_id}}
							</a>
						</li>
						</li>
					</ul>
				</li>
			  <li>
					<h3>Email</h3>
					<ul>
						<li ng-repeat="item in email">
							<a href="/panel.php?old=1&amp;page=email&amp;email={{item.hash}}">{{item.count}} - {{item.email}}</a>
						</li>
					</ul>
				</li>
			  <li>
					<h3>Liens Utiles</h3>
					<ul>
						<li><a href="/nopyj/">nopyj</a></li>
						<li><a href="/green/">anti fond-vert</a></li>
						<li><a href="/images/news/MDRLOL/">hébergeur d'image</a></li>
						<li><a href="/includes/irc.php">Admin IRC</a></li>
					</ul>
				</li>
			</ul>
		</div>
		<div class="col-sm-10 tab-content">
			<h3 class="col-md-6"><a href="/panel.php?page=infoserv&amp;serv={{serv.name}}">Serveur {{serv.name}}</a> &larr; C'est là pour start/stop/log </h3>
			<ul class="list-inline col-md-6 text-right">
				<li ng-repeat="filtre in filtres">
					<label> {{filtre[0]}} <input type="checkbox" name="selectedFiltre[]" value="{{name}}" checked ng-click="toggle(filtre[1])"> </label>
				</li>
			</ul>
			<ul class="list-unstyled">
				<li ng-repeat="line in log track by $index">{{line}}</li>
			</ul>

			<br clear="all" />
		</div>
	</div>

	<div class="col-md-8 col-md-offset-2">
		<h2>Gestion du roleplay</h2>
		<div class="form-horizontal">
			<div class="col-md-12">
				<input type="text" class="form-control" ng-model="steam" placeholder="STEAM_1:x:xxxxxx" />
			</div>
			<div class="col-md-6">
				<input type="text" class="form-control" ng-model="monFiltre" placeholder="nom d'un item" value="" />
			</div>
			<div class="col-md-6">
				<select class="form-control" ng-options="i.id as i.nom for i in itemsFiltred" ng-model="itemID"></select>
			</div>
			<div class="col-md-6">
				<input type="number" class="form-control" ng-model="amount" ng-init="0" placeholder="quantité" value="0" min="-10000000" max="10000000"/>
			</div>
			<div class="col-md-6">
				<select class="form-control" ng-options="i.id as i.name for i in jobs" ng-model="jobID"></select>
			</div>
		</div>
		<div class="row">
			<div class="form-inline col-md-offset-3">
				<input type="submit" class="form-control btn-success" value="Envoyer item" ng-click="submitItem()" />
				<input type="submit" class="form-control btn-mp" value="Argent / Job" ng-click="submitMoney()" />
				<input type="submit" class="form-control btn-forum" value="Envoyer XP" ng-click="submitXP()" />
			</div>
		</div>
		<h2>Gestion des réseaux sociaux</h2>
		<div class="form-horizontal">
			<div class="col-md-12">
				<input type="text" class="form-control" ng-model="titre" placeholder="titre" maxlength="128" />
			</div>
			<div class="col-md-12">
				<div class="input-group">
					<div class="input-group-addon" style="color: white;" ng-style="text.length >= 130 ? {'background-color': '#d9534f', 'border-color': '#d43f3a'} : {'background-color': '#5cb85c', 'border-color': '#4cae4c'}">{{text.length}}</div>
					<textarea class="form-control" ng-model="text" ng-init="text=''" placeholder="contenu"> </textarea>
				</div>
			</div>
			<div class="col-md-12">
				<input type="url" class="form-control" ng-model="url" placeholder="URL" />
			</div>
		</div>
		<div class="row">
			<div class="form-inline col-md-offset-3">
				<input type="submit" class="form-control btn-danger" value="Envoyer sans vérifier" ng-click="submitSocial()" />
				<input type="submit" class="form-control btn-success" value="Vérifier orthographe" ng-click="submitOrtho()" />
			</div>
		</div>
	</div>
	<br clear="all"/><br /><br /><br /><br />
	<div class="gauges">
		<div class="gauge">
			<div class="gauge-a"></div>
			<div class="gauge-b" style="transform: rotate({{cpu*1.8}}deg);"></div>
			<div class="gauge-c"></div>
			<div class="gauge-d">CPU<br />{{Math.round(cpu)}}%</div>
		</div>
		<div class="gauge">
			<div class="gauge-a"></div>
			<div class="gauge-b" style="transform: rotate({{mem*1.8}}deg);"></div>
			<div class="gauge-c"></div>
			<div class="gauge-d">MEM:<br />{{Math.round(mem)}}%</div>
		</div>
		<div class="gauge">
			<div class="gauge-a"></div>
			<div class="gauge-b" style="transform: rotate({{Math.min(180, load*25*1.8)}}deg);"></div>
			<div class="gauge-c"></div>
			<div class="gauge-d">LOAD:<br />{{Math.round(load*100)/100}}</div>
		</div>
		<div class="gauge">
			<div class="gauge-a"></div>
			<div class="gauge-b" style="transform: rotate({{Math.min(180,net*1.8)}}deg);"></div>
			<div class="gauge-c"></div>
			<div class="gauge-d">NET:<br />{{Math.round(net/100*(10*100))/100}} Mo</div>
		</div>
		<div class="gauge">
			<div class="gauge-a"></div>
			<div class="gauge-b" style="transform: rotate({{players/200*100*1.8}}deg);"></div>
			<div class="gauge-c"></div>
			<div class="gauge-d">Joueurs:<br />{{players}}</div>
		</div>
	</div>
</div>
