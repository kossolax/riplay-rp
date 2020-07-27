<div class="btn-group btn-group-justified" role="group">
  <a class="btn btn-default" href="#/tribunal/mine"> Vos rapports </a>
  <a class="btn btn-default" href="#/tribunal/last"> Les dernières condamnations </a>
  <a class="btn btn-default" href="#/tribunal/rules"> Participer au Tribunal </a>
  <a class="btn btn-default" href="#/tribunal/report"> Rapporter un mauvais comportement </a>
</div>
<table class="table">
  <thead>
    <tr>
        <th>Joueur</th>
        <th>Rapport</th>
        <th>Condamnation</th>
        <th>heures de prison</th>
        <th>Amende</th>
        <th>Juge</th>
    </tr>
  </thead>
  <tbody>
    <tr ng-repeat="item in report">
        <td><a href="#/tribunal/case/{{item.steamid}}">{{item.name}}</a></td>
        <td><a href="#/tribunal/case/{{item.id}}">{{item.report_raison}}</a></td>
        <td>{{item.timestamp*1000 | date}}<span class="label label-danger" ng-show="item.jail>0 || item.amende>0">Condamné</span><span class="label label-success" ng-show="item.jail==0 && item.amende==0">Acquitté</span></td>
        <td><span ng-show="item.jail>0 || item.amende>0">{{item.jail}} heures</span></td>
        <td><span ng-show="item.jail>0 || item.amende>0">{{item.amende}}$</span></td>
        <td><a href="#/tribunal/case/{{item.juge}}">{{item.jugeName}}</a></td>
        <br>
    </tr>
  </tbody>
</table>
