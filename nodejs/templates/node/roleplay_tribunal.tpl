<br />
<h2>Rapporter un mauvais comportement</h2>
  <h3>
    Certains joueurs ont malheureusement une attitude négative sur le serveur et ne respectent pas le règlement.
    Si vous avez des problèmes avec un joueur, et qu'un policier ou qu'un juge n'a rien pu faire, il est toujours possible de faire appliquer le règlement.
  </h3>

  <br /><br />

<form class="form-horizontal" ng-submit="report()">
  <div ng-controller="rpSteamIDLookup" class="form-group">
    <label class="col-md-3 control-label">Entrez le SteamID du joueur concerné</label>
    <div class="col-md-6">
      <div class="input-group" >
        <span class="input-group-addon" required="">SteamID:</span>
        <input type="text" class="form-control" ng-model="steamid" ng-change="$parent.typePolice='0'; $parent.steamid=steamid">
        <span class="input-group-addon">{{pData.name}}</span>
        <span class="input-group-addon"><i ng-show="valid" class="fa fa-check text-success"></i><i ng-hide="valid" class="fa fa-times text-danger"></i></span>
      </div>
    </div>
    <div class="col-md-3">
      <a class="btn btn-default" ng-click="$parent.showDialog=true">Vous ne connaissez pas son steamID?</a>
    </div>
  </div>
  <div class="form-group">
    <label class="col-md-3 control-label">Quand les faits se sont-ils déroulés?</label>
    <div class="col-md-6">
      <div class="input-group">
        <span class="input-group-addon" required="">Date, heure:</span>
        <input name="nowDate" type="text" class="form-control" ng-model="nowDate" required ng-pattern="/^le ([0-9]{1,2})/([0-9]{1,2}) à ([0-9]{1,2}):([0-9]{1,2})$/">
        <span class="input-group-addon"><i ng-show="nowDate" class="fa fa-check text-success"></i><i ng-hide="nowDate" class="fa fa-times text-danger"></i></span>
      </div>
    </div>
  </div>
  <div class="form-group" ng-show="pData.job_id>=1&&pData.job_id<=9||pData.job_id>=101&&pData.job_id<=109">
    <label class="col-md-3 control-label">Il s'agit d'un policier:</label>
    <div class="col-md-6" ng-init="typePolice='0'">
      <select class="form-control" ng-change="(typePolice==1?reason=reasonCT:reason=reasonT)" ng-model="typePolice">
        <option value="0" default>Il était en civil, c'était hors de ses fonctions</option>
        <option value="1">Il était CT, c'était pendant ses fonctions.</option>
      </select>
    </div>
  </div>
  <div class="form-group">
    <label class="col-md-3 control-label">Raison:</label>
    <div ng-class="(rType=='Autre, préciser:'?'col-md-3':'col-md-6')">
      <div class="input-group">
        <select class="form-control" required="required" ng-model='rType' ng-options="str for str in reason" ng-change="rType2=''"></select>
        <span class="input-group-addon"><i ng-show="rType.length>0" class="fa fa-check text-success"></i><i ng-hide="rType.length>0" class="fa fa-times text-danger"></i></span>
      </div>
    </div>
    <div class="col-md-3" ng-show="rType=='Autre, préciser:'">
      <div class="input-group">
        <input type="text" class="form-control" ng-model="rType2" />
        <span class="input-group-addon"><i ng-show="rType2.length>0" class="fa fa-check text-success"></i><i ng-hide="rType2.length>0" class="fa fa-times text-danger"></i></span>
      </div>
    </div>
  </div>
  <div class="form-group">
		<label class="col-md-3 control-label">Informations: </label>
		<div class="col-md-6">
      <div class="input-group">
        <textarea name="moreinfo" style="resize:vertical;" class="form-control text-warning" required="required" ng-model="moreInfo" minlength="10" maxlength="255"></textarea>
        <span class="input-group-addon"><i ng-show="(moreInfo.length>=10)" class="fa fa-check text-success"></i><i ng-hide="(moreInfo.length>=10)" class="fa fa-times text-danger"></i></span>
      </div>
    </div>
	</div>
  <div class="form-group">
		<div class="col-md-9 text-right"> <input type="submit" class="btn" ng-class="valid&&nowDate&&rType.length>0&&moreInfo.length>10?'btn-success':'btn-default disabled'" value="Envoyer">	</div>
	</div>

  <br clear="all" />
</form>

<div modal-show="showDialog" class="modal fade">
  <div class="modal-dialog" ng-controller="rpSteamIDLookup">
    <div class="modal-content">
      <div class="modal-body" ng-include="'templates/node/roleplay_search.tpl'"></div>
      <div class="modal-footer">
        <button class="btn btn-default" data-dismiss="modal">Quitter</button>
      </div>
    </div>
  </div>
</div>
