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
    opacity: 0.5;
  }
  .img-overlay i.fa-ban {
    color: red;
  }
  .img-overlay i.fa-check {
    color: green;
  }

</style>

<br clear="all"/>
<table class="col-md-10 col-md-offset-1">
  <t-body>
  <tr ng-repeat="item in data">
    <td class="img-overlay" style="padding-top: 15px"><img src="/images/icons/{{item.game}}.png" width="64" height="64" />
      <i ng-show="item.banned==1" class="fa fa-ban fa-5x" aria-hidden="true"></i>
      <i ng-show="item.banned==0" class="fa fa-check fa-5x" aria-hidden="true"></i>
    </td>
    <td width="10"></td>
    <td style="padding-top: 15px">
      <a href="#/pilori/view/{{item.SteamID}}">{{item.nick}}</a> {{item.game | prettyBan}},
      <span ng-hide="item.Length">de façon Permanente.
        <i ng-show="item.banned==1">Cette sanction ne peut-être levée que par la clémence d'un admin.</i>
      </span>
      <span ng-show="item.Length">pour une durée de {{item.Length | fullDuration }}. <br />
        <i ng-show="item.banned==1">Cette sanction sera levée à {{ (item.Length + item.StartTime) * 1000 | date: "HH'h'mm, le dd-MM-yy" }}.</i>
      </span>
    <br />
      La raison de cette sanction est: <u><b>{{item.reason}}</b></u>.
      <span ng-show="item.banned==0">
        <i ng-hide="item.unban==1">Cette sanction est terminée.</i>
        <i ng-show="item.unban==1">Un admin vous a accordé sa clémence.</i>
      </span>

      <span ng-show="item.SteamID==steamid && item.banned==1">Vous pouvez contester en postant <a href="https://www.ts-x.eu/forum/posting.php?mode=post&f=56">ici</a>.</span>
    </td>
  </tr>
  <tr>
    <td style="padding-top: 15px">
      <a href="#/pilori/last/{{(paramsSub | num)-1}}" class="btn btn-default pull-left" ng-show="(paramsSub | num)>0"> Précédent </a>
      <a href="#/pilori/last/{{(paramsSub | num)+1}}" class="btn btn-default pull-right"> Suivant </a>
    </td>
  </tr>
</table>
