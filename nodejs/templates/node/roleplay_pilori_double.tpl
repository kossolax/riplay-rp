<div class="btn-group btn-group-justified" role="group">
  <a class="btn btn-default" href="#/pilori/view/{{steamid}}"> Vos sanctions </a>
  <a class="btn btn-default" href="#/pilori/double/{{steamid}}"> Vos doubles comptes </a>
  <a class="btn btn-default" href="#/pilori/last/0"> Les dernières condamnations </a>
</div>
<form ng-show="isAdmin || $parent.isAdmin">
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

<div class="col-md-10 col-md-offset-1 alert alert-warning" role="alert" ng-show="data.length > 0">
  <strong>L'utilisation d'un double compte est tolérée</strong> mais aucune action ne doit être entreprise pour le second compte (pas de transaction, HDV, give, réduction, etc).
  Les déconnexions intempestives, pour changer de compte, ne sont pas autorisées. <i>Exemple : Je me suis fait mettre en prison, du coup je change de compte...</i>
  <br />
  Le Rang "No-pyj" ne peut être obtenu que sur un seul de vos comptes.
</div>

<div class="col-md-10 col-md-offset-1 alert alert-success" role="alert" ng-show="data.length <= 0">
  <strong>Aucun double compte détecté <i class="fa fa-thumbs-up" aria-hidden="true"></i> </strong> L'utilisation d'un double compte est tolérée, mais aucune action ne doit être entreprise en faveur du second compte.
</div>

<table ng-init="target=''" class="table table-condensed" ng-show="data.length > 0">
  <tr><th>SteamID</th><th>Pseudo</th><th>Job</th><th ng-if="steamid==paramsSub">Contester?</th></tr>
  <tr ng-repeat="item in data" ng-show="item!=paramsSub">
    <td>{{item}}</td>
    <td>{{fullData[item].name}}</td>
    <td>{{fullData[item].job_name}}</td>
    <td ng-show="steamid==paramsSub"><a class="btn btn-default" ng-click="$parent.showDialog = true; $parent.target = item; $parent.pData = fullData[item];">Contester</a></td>
  </tr>
</table>

<div modal-show="showDialog" class="modal fade">
  <div class="modal-dialog">
    <form>
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">&times;</button>
          <h4 class="modal-title">Contester un double compte</h4>
        </div>
        <div class="modal-body">
          <div class="input-group">
            <span class="input-group-addon" required>SteamID:</span>
            <input type="text" class="form-control" ng-model="target" disabled />
            <span class="input-group-addon">{{pData.name}}</span>
          </div>
          <div class="input-group">
            <span class="input-group-addon">Raison:</span>
            <select class="form-control" ng-model="reason">
              <option value="2">Il s'agit d'un membre de ma famille</option>
              <option value="0">Il s'agit un proche qui est venu chez moi</option>
              <option value="2">Il s'agit d'un ancien compte que je n'ai plus accès</option>
              <option value="0">Il s'agit d'une erreur, je n'ai pas partagé mon compte avec lui</option>
              <option value="0">J'ai partagé mon compte avec lui, mais il n'a plus accès.</option>
              <option value="0">Je ne sais pas qui c'est</option>
              <option value="0">Autres, je souhaite être recontacté</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-warning" data-dismiss="modal">Annuler</button>
          <input class="btn" type="submit" value="Envoyer" rest="put@/user/double/deny/{{target}}/{{reason}}" ng-click="showDialog = false; reloadTimer(2500);" />
        </div>
      </div>
    </form>
  </div>
</div>
