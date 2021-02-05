<div class="btn-group btn-group-justified" role="group">
  <a class="btn btn-default" href="#/pilori/view/{{steamid}}"> Vos sanctions </a>
  <a class="btn btn-default" href="#/pilori/double/{{steamid}}"> Vos doubles comptes </a>
  <a class="btn btn-default" href="#/pilori/last/0"> Les dernières condamnations </a>
</div>
<form ng-show="isAdmin">
  <div class="form-inline">
		<div class="input-group">
			<input type="text" class="form-control" placeholder="STEAM_0:x:abcdef" ng-model="target">
		</div>
		<div class="input-group">
			<input type="text" class="form-control" placeholder="1440 temps en minutes" ng-model="time">
		</div>
		<div class="input-group">
			<input type="text" class="form-control" placeholder="Raison..." ng-model="reason">
		</div>
		<div class="input-group">
			<select name="game" class="form-control" ng-model="game"><option value="csgo">Counter-Strike: GO</option><option value="rp-kill">Roleplay: KILL</option><option value="rp-pvp">Roleplay: PvP</option><option value="rp-global">Roleplay: Chat Global</option><option value="rp-vocal">Roleplay: Chat Vocal</option><option value="rp-local">Roleplay: Chat Local</option><option value="rp-event">Roleplay: Event</option><option value="tf">Team Fortress</option><option value="forum">FORUM</option><option value="teamspeak">TeamSpeak</option><option value="ALL">Global</option><option value="teamspeak">TeamSpeak</option><option value="tribunal">Tribunal</option></select>
		</div>
		<div class="input-group">
      <a class="btn btn-default" rest="put@/user/pilori/{{target}}/{{time}}/{{game}}/{{reason}}">Bannir</a>
    </div>
  </div>
</form>
<br />
<style>
  .img-overlay {
    position: relative;
    display: inline-block;
    float: right;
    width: 64px;
    height: 64px;
    text-align: center;
  }
  .img-overlay i {
    position: absolute;
    top: 50%;
    left: 0;
    right: 0;
    transform: translateY(-50%);
    color: red;
    opacity: 0.5;
  }
</style>

<div class="col-md-8 col-md-offset-2 alert alert-warning" role="alert" ng-repeat="(k,v) in next.count" ng-if="k=='irrespect' && v>0">
  <strong>Attention, nous sanctionnons le mauvais comportement de plus en plus sévèrement.</strong>
  Vous avez été récement sanctionné {{v}} fois pour {{k}}. La prochaine fois, vous risquez une sanction de {{ getBanDuration(k,v)*60 | fullDuration }}.
</div>

<table class="col-md-8 col-md-offset-2">
  <tr ng-hide="banned==0"><th colspan="3"><h2>Vos sanctions en cours</h2></th></tr>
  <tr ng-repeat="item in data" ng-if="item.banned==1">
    <td class="img-overlay"><img src="/images/icons/{{item.game}}.png" width="64" height="64" /><i class="fa fa-ban fa-5x" aria-hidden="true"></i></td>
    <td width="10"></td>
    <td>
      Vous avez été interdit de {{item.game | prettyBan}},
      <span ng-hide="item.Length">de façon Permanente. Cette sanction ne peut-être levée que par la clémence d'un admin.</span>
      <span ng-show="item.Length">pour une durée de {{item.Length | fullDuration }}. <br /> Cette sanction sera levée à {{ (item.Length + item.StartTime) * 1000 | date: "HH'h'mm, le dd-MM-yy" }}.</span>
    <br />
      La raison de cette sanction est: <u><b>{{item.reason}}</b></u>.
      <span ng-show="Params.sub==steamid">Vous pouvez contester en postant <a href="https://forum.riplay.fr/index.php?/topic/89-a-lire-avant-de-poster-demande-de-d%C3%A9bannissement/">ici</a>.</span>
    </td>
  </tr>

  <tr ng-hide="data.length-banned==0"><th colspan="3"><h2>Vos sanctions passées</h2></th></tr>
  <tr ng-repeat="item in data" ng-if="item.banned==0">
    <td class="img-overlay"><img src="/images/icons/{{item.game}}.png" width="64" height="64" /><i class="fa fa-ban fa-5x" aria-hidden="true"></i></td>
    <td width="10"></td>
    <td>
      Vous avez été interdit de {{item.game | prettyBan}},
      <span ng-hide="item.Length">de façon Permanente.</span>
      <span ng-show="item.Length">pour une durée de {{item.Length | fullDuration }}.</span>
      <br />
      La raison de cette sanction est: <u><b>{{item.reason}}</b></u>.
      <span ng-hide="item.unban==1">Cette sanction est terminée.</span>
      <span ng-show="item.unban==1">Un admin vous a accordé sa clémence.</span>

    </td>
  </tr>
</table>
<br clear="all" />
