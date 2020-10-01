<script type="text/javascript">
	var app = angular.module("tsx", []);
	app.controller('ctrl', function($scope, $http, $filter) {
		$http.defaults.headers.common['auth'] = '{$_COOKIE['tsxcookiev3_sid']}';
		$scope.steamid = '{$steamid}';

		$scope.time = $filter('date')(new Date(), 'HH:mm');

        $scope.getTitleName = function( item ) {
            var ret = item.title + " du "+ $filter('date')( new Date(item.timestamp*1000), 'dd/MM à HH:mm');
            if( item.seen == 0 )
                ret += ' - NOUVEAU MESSAGE';
            return ret;
        }
		$scope.update = function(id) {
			$http.get("https://www.ts-x.eu/api/report/"+id).success(function (response) { $scope.plainte = response[0]; });
			$http.get("https://www.ts-x.eu/api/report/"+id+"/response").success(function (response) { $scope.response = response; });
            $http.get("https://www.ts-x.eu/api/report/"+id+"/log").success(function (response) { $scope.logs = response; });
		}
        $scope.lock = function() {
            $http.put("https://www.ts-x.eu/api/report/"+$scope.myself, {lock: 1}).success(function (response) {

            });
        }
		$scope.reply = function() {
			$scope.rapportReply = $scope.rapportReply.trim();
			if( $scope.rapportReply == "" )
				return;

			$http.post("https://www.ts-x.eu/api/report/"+$scope.myself+"/reply", {text: $scope.rapportReply}).success(function (response) {
				$scope.response.unshift({name: $scope.me.name, steamid: $scope.steamid, text: $scope.rapportReply});
				$scope.rapportReply = "";
			});
		}
		$scope.send = function() {
            var a = $scope.time.split(":");
            var now = new Date();
            now.setHours( parseInt(a[0]) );
            now.setMinutes( parseInt(a[1]) );

            $http.post("https://www.ts-x.eu/api/report/police", {steamid: $scope.cops, timestamp: now, reason: $scope.reason, moreinfo: $scope.moreinfo}).success(function (response) {

                if( response.id !== undefined ) {
                    MakingAlert("Envois d'un rapport: Ok!", "Votre rapport a été envoyé, il va maintenant être lu par des référés. Ce sont des personnes n'étant ni policier, ni admin.");

                    $scope.update( response.id );
                    $http.get("https://www.ts-x.eu/api/report").success(function (res) { $scope.reports = res; $scope.myself = response.id; });

                    $('#list').tab('show');
                    $('#myTabs a[href="#list"]').tab('show')
                }
                else {
                    MakingAlert("Envois d'un rapport: Erreur", response);
                }
			});
            $scope.moreinfo = "";
		}

		$http.get("https://www.ts-x.eu/api/jobs/1/users").success(function (response) { $scope.polices = response; $scope.cops = response[0].steamid; });
		$http.get("https://www.ts-x.eu/api/jobs/101/users").success(function (response) { $scope.justices = response; });
		$http.get("https://www.ts-x.eu/api/user/"+$scope.steamid).success(function (response) { $scope.me = response; });
		$http.get("https://www.ts-x.eu/api/report").success(function (response) { $scope.reports = response; $scope.update(response[0].id); $scope.myself = response[0].id; });
	});
</script>
<style>
.well { margin-bottom: 2px; white-space: pre-wrap; }
pre.well > img { margin-right: 5px; }
</style>

<div class="col-md-12" ng-app="app">
	<h2>Victime d'un mauvais comportement d'un joueur?</h2>

    <h3>Cette page est en BETA, rapportez tout problème éventuel à kossolax@ts-x.eu</h3>

	<ul class="nav nav-tabs" role="tablist" id="myTabs">
		<li style="width:33%;"><a href="#player" aria-controls="player" role="tab" data-toggle="tab">Rapporter un joueur</a></li>
		<li class="active" style="width:33%;"><a href="#report" aria-controls="report" role="tab" data-toggle="tab">Rapporter un policier</a></li>
		<li style="width:33%;"><a href="#list" aria-controls="list" role="tab" data-toggle="tab">Vos rapports sur la police</a></li>
	</ul>
	<div class="tab-content col-md-12" ng-controller="ctrl">
		<div role="tabpanel" class="tab-pane row" id="player">
			<h3>soon.</h3>
			<center>
				<img src="http://anaisgirod.fr/images/website_under_construction.png" />
			</center>
		</div>
		<div role="tabpanel" class="tab-pane active row" id="report">
			<h3>Rapporter un policier</h3>
			<p>
				Vous avez été victime d'une violence policière ? Remplisser ce formulaire, et on se charge du reste.
			</p>
			<hr />
			<form class="form-horizontal"  ng-submit="send()">
				<div class="form-group">
					<label class="col-sm-2 control-label">Joueur: </label>
					<div class="col-sm-6 col-md-offset-1">
						<select name="steamid" class="form-control" required="required" ng-model="cops">
							<optgroup label="La police">
								<option ng-repeat="item in polices" value="{{item.steamid}}">{{item.name}} - {{item.nick}}</option>
							</optgroup>
							<optgroup label="La justice">
								<option ng-repeat="item in justices" value="{{item.steamid}}">{{item.name}} - {{item.nick}}</option>
							</optgroup>
						</select>
					</div>
				</div>
				<div class="form-group">
					<label class="col-sm-2 control-label">L'heure IRL des faits:<br /><i>Ex: 09:50 pour 9h50 du matin</i></label>
					<div class="col-sm-6 col-md-offset-1">
						<input type="text" ng-model="time" placeholder="HH:mm" class="form-control" required placeholder="HH:mm" />
					</div>
				</div>
				<div class="form-group">
					<label class="col-sm-2 control-label">Raison: </label>
					<div class="col-sm-6 col-md-offset-1">
						<select name="reason" class="form-control" required="required" ng-init="reason = 'Jail dans une propriétée privée'" ng-model="reason">
							<option>Jail dans une propriétée privée</option>
							<option>Abus de ses fonctions</option>
							<option>Abus de /jail</option>
							<option>Jail par déduction</option>
							<option>Freekill en fonction</option>
							<option>Abus de perquisition</option>
							<option>Autre, précisez :</option>
						</select>
					</div>
				</div>
				<div class="form-group">
					<label class="col-sm-2 control-label">Informations supplémentaires: </label>
					<div class="col-sm-6 col-md-offset-1">
						<textarea class="form-control" required="required" ng-model="moreinfo"></textarea>
					</div>
				</div>
				<div class="form-group">
					<div class="col-sm-offset-8 col-sm-2">
						<input type="submit" value="Envoyer le rapport" class="btn btn-warning" />
					</div>
				</div>
			</form>
		</div>
		<div role="tabpanel" class="tab-pane row" id="list">
			<h3>Vos rapports</h3>
			<form class="form-horizontal">
				<div class="form-group">
					<label class="col-sm-1 control-label">Rapport: </label>
					<div class="col-sm-9 col-sm-offset-1">
						<select class="form-control" ng-options="item.id as getTitleName(item) for item in reports | orderBy:['group']" ng-model="myself" ng-change="update(myself)" ></select>
					</div>
				</div>
				<hr />
				<h4>{{plainte.title}} du {{(plainte.timestamp*1000) | date: 'dd/MM à HH:mm'}}:</h4>
				<table style="text-align:center; width:100%;">
					<tr>
						<td><img class="img-polaroid" src="//www.ts-x.eu/do/steam_avatar/steamid/{{plainte.steamid}}.jpg" width="100" height="100"/></td>
						<td>VS</td>
						<td><img class="img-polaroid" src="//www.ts-x.eu/do/steam_avatar/steamid/{{plainte.reportSteamID}}.jpg" width="100" height="100"/></td>
					</tr>
					<tr>
						<td>{{plainte.name}}</td>
						<td></td>
						<td>{{plainte.reportName}}</td>
					</tr>
				</table>
				<ul class="nav nav-tabs" role="tablist">
					<li class="active" style="width:33%;"><a href="#chat" aria-controls="chat" role="tab" data-toggle="tab">Chat</a></li>
					<li style="width:33%;"><a href="#log" aria-controls="log" role="tab" data-toggle="tab">Logs: {{plainte.reportName}}</a></li>
					<li style="width:33%;"><a href="#log2" aria-controls="log2" role="tab" data-toggle="tab">Logs: {{plainte.name}}</a></li>
				</ul>
				<div class="tab-content col-md-12">
					<div role="tabpanel" class="tab-pane active row" id="chat">
						<pre class="well well-sm clearfix" ng-hide="plainte.lock == 1">
                            <img class="img-polaroid img-circle pull-left" src="//www.ts-x.eu/do/steam_avatar/steamid/{$steamid}.jpg" width="50" height="50"/><b>{{me.name}}</b>: <br /><div class="col-md-11"><textarea class="form-control pull-left" ng-model="rapportReply"></textarea></div><br /><input class="btn btn-success col-md-1 col-md-offset-10" type="submit" value="Envoyer" ng-click="reply()"/><input class="btn btn-warning col-md-1" type="submit" value="Lock" ng-click="lock()" ng-hide="!plainte.admin" /></pre>
						<pre class="well well-sm clearfix" ng-repeat="item in response"><img class="img-polaroid img-circle pull-left" src="//www.ts-x.eu/do/steam_avatar/steamid/{{item.steamid}}.jpg" width="50" height="50"/><b>{{item.name}}</b>: {{item.text}}</pre>
						<pre class="well well-sm clearfix"><img class="img-polaroid img-circle pull-left" src="//www.ts-x.eu/do/steam_avatar/steamid/{{plainte.steamid}}.jpg" width="50" height="50"/><b>{{plainte.name}}</b>: {{plainte.text}}</pre>
					</div>
					<div role="tabpanel" class="tab-pane row" id="log">
                        <span class="small text-muted" ng-repeat="item in logs[1] track by $index">{{item}}<br /></span>
                    </div>
					<div role="tabpanel" class="tab-pane row" id="log2">
                        <span class="small text-muted" ng-repeat="item in logs[0] track by $index">{{item}}<br /></span>
                    </div>
				</div>

			</form>
		</div>
	</div>
</div>
