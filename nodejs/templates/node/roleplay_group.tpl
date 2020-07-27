<div style="background-color:rgba({{data.color}}, 0.025); padding:5px 5px 5px 5px; border:1px solid rgba({{data.color}}, 0.1); border-bottom-left-radius:5px; border-bottom-right-radius:5px;">
  <h2 style="text-shadow:0px 0px 10px rgb({{data.color}}); color:rgb({{data.color}});">Groupe: {{data.name}} </h2>
  <div class="col-sm-2">
  </div>
  <div class="col-sm-8">
    <img src="/images/roleplay/group/{{subParams}}.jpg" width="800" height="200" class="img-polaroid">
  </div>
  <div class="col-sm-2">
  </div>
  <br clear="all">
  <div class="row">
    <div class="col-sm-6">
      <br /><br /><br /><br /><br /><br />
      <table width="100%" class="table-hover table-condensed">
        <tr>
          <th class="pull-right">Joueurs:</th>
          <th class="text-center" ng-class="(players.length-10)>=-2 ? 'text-success' : (players.length-10)>=-4 ? 'text-warning' : 'text-danger'">{{players.length}} / 10</th>
          <th>Rangs:</th>
          <th>Points:</th>
        </tr>
        <tr ng-repeat="player in players" >
          <td class="pull-right"><a href="#/user/{{player.steamid}}" ng-class="(player.active? '' : 'text-danger')">{{player.nick}}</a></td>
          <td class="text-center"></td>
          <td>
            <a ng-show="$parent.isAdmin" style="cursor:pointer;" data-ng-click="$parent.steamid = player.steamid; $parent.updateSteamID(); $parent.toggleModal();">{{player.name}} <i class="fa fa-wrench"></i></a>
            <span ng-hide="$parent.isAdmin">{{player.name}}</span>
          </td>
          <td>{{player.point}}</td>
        </tr>
        <tr ng-show="isAdmin">
          <td></td><td></td>
          <td><a style="cursor:pointer;" data-ng-click="steamid = '123456789101112'; updateSteamID(); toggleModal();">Nouveau <i class="fa fa-plus"></i></a></td>
        </tr>
      </table>
    </div>
    <div class="col-sm-6">
      <img style="width:300px; height:410px;" src="/images/roleplay/skin/{{data.skin}}.bmp.png" />
    </div>
  </div>

  <div modal-show="showDialog" class="modal fade">
    <div class="modal-dialog" ng-controller="rpSteamIDLookup">
      <form ng-submit="$parent.UpdateData(pData.group_id)">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal">&times;</button>
            <h4 class="modal-title">Gestion du groupe</h4>
          </div>
          <div class="modal-body">
            <div class="input-group">
              <span class="input-group-addon" required>SteamID:</span>
              <input type="text" class="form-control" ng-model="$parent.steamid" ng-change="updateSteamID()" />
              <span class="input-group-addon">{{pData.name}}</span>
            </div>
            <div class="input-group">
              <span class="input-group-addon">Rang:</span>
              <select class="form-control" required ng-options="item.id as item.name for item in data.sub" ng-model="pData.group_id"></select>
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
</div>
