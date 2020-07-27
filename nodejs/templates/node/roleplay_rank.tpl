<style>
tr.bad { background-color: #af2a2a; }
</style>
<h2>Le classement {{Params.sub}}:</h2>
<div ng-hide="data" class="text-center"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-{{i}}x"></i></div>

<div class="col-sm-12 alert alert-warning" role="alert" ng-show="Params.sub=='freekill2'">
	<strong>Attention, dans ce classement les joueurs ayant plus de 250 points sont sanctionnés.</strong>
	Il s'agit d'un comportement néfaste, non désiré sur notre serveur. Ce classement fonctionne en comptant votre meurtre consécutif sans mourir.
	Le classement additionne ensuite les résultats sur les 31 derniers jours du serveur. Si vous dépassez les 250 meurtres sans mourir, vous êtes sanctionné.
</div>
<div class="col-sm-12 alert alert-warning" role="alert" ng-show="Params.sub=='freekill'">
        <strong>Attention, dans ce classement les joueurs gagnant plus de 25 points en une journée sont sanctionnés.</strong>
        Il s'agit d'un comportement néfaste, non désiré sur notre serveur. Ce classement fonctionne en comptant votre meurtre consécutif sans mourir.
        Si vous dépassez les 25 meurtres sans mourir en une seule journée, vous êtes sanctionné.
</div>

<table class="table">
  <thead>
    <tr><th>Pos.</th><th>Joueur:</th><th></th><th>Grade:</th><th>Point:</th></tr>
  </thead>
  <tbody>
    <tr ng-repeat="item in data" ng-init="steamid=item[0]; name=item[1]; rank=item[2]; old_rank=item[3]; point=item[4]; old_point=item[5];" ng-class="{
	bad: ((Params.sub=='freekill2' && point>=250) || (Params.sub=='freekill' && (point-old_point)>=25)),
	active: ($parent.steamid==steamid) }">
      <td>{{rank}}
        <span ng-show="old_rank-rank<0" class="label label-warning">{{old_rank-rank}}</span>
        <span ng-show="old_rank-rank>0" class="label label-success">+{{old_rank-rank}}</span>
        <span ng-show="old_rank-rank==0" class="label label-info">=</span>
      </td>
      <td>{{steamid}}</td>
      <td><a href="#/user/{{steamid}}">{{name}}</a></td>
      <td>{{getRank(rank, point)}}</td>
      <td>{{point}}
        <span ng-show="point-old_point<0" class="label label-warning">{{(point-old_point)}}</span>
        <span ng-show="point-old_point>0" class="label label-success">{{(point-old_point)}}</span>
      </td>
    </tr>
  </tbody>
</table>
