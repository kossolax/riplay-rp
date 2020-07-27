<h2>Job: {{data.name}} </h2>
<div class="row">
  <div class="col-sm-2">
  </div>
  <div class="col-sm-8">
    <img src="/images/roleplay/job/{{subParams}}.jpg" width="800" height="200" class="img-polaroid">
  </div>
  <div class="col-sm-2">
  </div>
</div>
<br />
<div class="row">
  <div class="col-sm-5 col-sm-offset-1">
    <ul class="nav nav-tabs" role="tablist" id="myTabs">
  		<li><a href="#/{{routeArgs}}/{{subParams}}?TABS=player">Membres</a></li>
  		<li><a href="#/{{routeArgs}}/{{subParams}}?TABS=best">Le top</a></li>
      <li><a href="#/{{routeArgs}}/{{subParams}}?TABS=tree">Hiérarchies</a></li>
  	</ul>
    <div class="tab-content col-md-12">
      <div role="tabpanel" class="tab-pane active row" id="player">
        <h3>Les membres</h3>
        <table width="100%" class="table-hover table-condensed">
          <tr>
            <th class="text-right" >Joueurs:</th>
            <th class="text-center" ng-class="(data.current-data.quota)>0 ? 'text-success' : (data.current-data.quota)>-2 ? 'text-warning' : 'text-danger'">{{data.current}} / {{data.quota}}</th>
            <th>Rangs:</th>
          </tr>
          <tr ng-repeat="player in players" data-toggle="tooltip" title="{{secondsToHours(player.TimePlayedJob)}} heures dans ce job">
            <td class="text-right"><a href="#/user/{{player.steamid}}" ng-class="(player.active? (player.TimePlayedJob>30*60?'':'text-warning') : 'text-danger')">{{player.nick}}</a></td>
            <td></td>
            <td>
              <a ng-show="$parent.isAdmin" style="cursor:pointer;" data-ng-click="$parent.steamid = player.steamid; $parent.toggleModal();">{{player.name}}  <i class="fa fa-wrench"></i></a>
              <span ng-hide="$parent.isAdmin">{{player.name}}</span>
            </td>
          </tr>
          <tr ng-show="isAdmin">
            <td></td><td></td>
            <td><a style="cursor:pointer;" data-ng-click="steamid = 'STEAM_1:x:xxxxx'; toggleModal();">Nouveau <i class="fa fa-plus"></i></a></td>
          </tr>
        </table>
      </div>

      <div role="tabpanel" class="tab-pane row" id="best">
        <h3>Les meilleurs membres</h3>
        <ol>
          <table width="100%">
            <tr><th>Rang:</th><th class="text-right">Pseudo:</th><th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th><th>Gain:</th></tr>
            <tr ng-repeat="player in PlayerTop" ><td>{{$index+1}}</td><td class="text-right"><a href="#/user/{{player.steamid}}">{{player.name}}</a></td><td></td><td>{{player.total | number}}$</td></tr>
          </table>
        </ol>
      </div>
      <div role="tabpanel" class="tab-pane row" id="tree">
        <h3>La hériarchie</h3>
        <ol>
          <table width="100%">
            <tr><th class="text-right" >Rang:</th><th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th><th>Paye:</th></tr>
            <tr ng-repeat="player in data.sub" ng-if="player.id!=0" ><td class="text-right">{{player.name}}</a></td><td></td><td>{{player.pay | number}}$</td></tr>
          </table>
        </ol>
      </div>
    </div>
  </div>
  <div class="col-md-5">
    <h3> Les notes  <button class="btn btn-warning" ng-hide="data.approuved" ng-show="$parent.isAdmin" rest="put@/job/{{subParams}}/approuve">Valider</button> </h3>
    <img ng-show="data.approuved" class="pull-right" src="/images/approuved.png" width="100"/>


    <ul class="list-unstyled" dnd-list="data.notes">
      <li ng-repeat="item in data.notes" ng-class="item.approuved?'':'bg-danger'" dnd-draggable="item" dnd-moved="data.notes.splice($index, 1);" dnd-dragend="dropCallback(event, $index, item);">
        <span ng-show="isAdmin">
          <a href class="fa fa-arrows"></a>
          <a href class="fa fa-trash-o" rest="delete@/job/{{subParams}}/note/{{item.id}}" ng-click="data.notes.splice($index, 1);"></a>
          -
          <a href ng-click="$parent.laNote = item; $parent.editShowNote = true;">
            {{item.name}}
          </a>
        </span>
        <span ng-hide="isAdmin">{{item.name}}</span>
      </li>
    </ul>
  </div>
</div> <br />
<div class="row" ng-show="items.length > 0">
  <h3><u>Les objets à vendre :</u></h3>
  <ul class="list-inline">
    <li ng-repeat="item in items">
      <img class="img-circle" width="100" height="100" src="/images/roleplay/csgo/items/{{item.id}}.png"
        data-toggle="popover" data-placement="top" title="{{item.nom}} <i class=\'pull-right text-success\'>{{item.prix}}$</i>" data-content="{{item.description}}" />
    </li>
  </ul>
  <span ng-show="subParams==81">
  <!--<div ng-include="'/templates/tpl/aide/job/drogues.tpl'"></div>-->
  </span>
  <span ng-show="subParams==71">
  <!--<div ng-include="'/templates/tpl/aide/job/skin.tpl'"></div>-->
  </span>
</div>
<div modal-show="showDialog" class="modal fade">
  <div class="modal-dialog" ng-controller="rpSteamIDLookup">
    <form ng-submit="$parent.UpdateData(pData.job_id)">
      <div class="modal-content" >
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">&times;</button>
          <h4 class="modal-title">Gestion du job</h4>
        </div>
        <div class="modal-body">
          <div class="input-group">
            <span class="input-group-addon" required>SteamID:</span>
            <input type="text" class="form-control" ng-model="$parent.steamid" />
            <span class="input-group-addon">{{pData.name}}</span>
          </div>
          <div class="input-group">
            <span class="input-group-addon">Rang:</span>
            <select class="form-control" required ng-options="item.id as item.name for item in data.sub" ng-model="pData.job_id"></select>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-warning" data-dismiss="modal">Annuler</button>
          <input class="btn" type="submit" ng-class="valid ? 'btn-success' : 'disabled btn-warning'" value="Envoyer" />
        </div>
      </div>
    </form>
  </div>
</div>
<div modal-show="editShowNote" class="modal fade">
  <div class="modal-dialog">
    <form ng-submit="UpdateNote(laNote.id)">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">&times;</button>
          <h4 class="modal-title">Gestion des notes</h4>
        </div>
        <div class="modal-body">
          <div class="input-group">
            <span class="input-group-addon" required>Note:</span>
            <input type="text" class="form-control" ng-model="laNote.name" />
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-warning" data-dismiss="modal">Annuler</button>
          <input class="btn" type="submit" ng-class="valid ? 'btn-success' : 'disabled btn-warning'" value="Envoyer" />
        </div>
      </div>
    </form>
  </div>
</div>

<div id="graph" draw-user-chart="https://riplay.fr/api/jobs/{{subParams}}/capital/6" style="height: 460px; margin: 0 auto"></div>
