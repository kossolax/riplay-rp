<div class="btn-group btn-group-justified" role="group">
  <a class="btn btn-default" href="#/tribunal/mine"> Vos rapports </a>
  <a class="btn btn-default" href="#/tribunal/last"> Les dernières condamnations </a>
  <a class="btn btn-default" href="#/tribunal/rules"> Participer au Tribunal </a>
  <a class="btn btn-default" href="#/tribunal/report"> Rapporter un mauvais comportement </a>
</div>
<br />
<h3>Tribunal de police</h3> <button class="btn btn-warning" rest="post@/report/read">Tous marqué comme lu</button>
<table class="table">
  <thead>
    <tr>
        <th>Joueur</th>
        <th>Rapport</th>
        <th>Date</th>
    </tr>
  </thead>
  <tbody>
    <tr ng-repeat="item in reportPolice">
      <td><a href="#/tribunal/phone/{{item.id}}">{{item.plaignant}} vs {{item.name}}</a></td>
      <td><a href="#/tribunal/phone/{{item.id}}">{{item.title}} </a> <span class="label label-success" ng-show="item.seen==0"> - NOUVEAU</span></td>
      <td>{{item.timestamp*1000 | date}}</td>
    </tr>
  </tbody>
</table>
<h3>Tribunal forum</h3>
<table class="table">
  <thead>
    <tr>
        <th>Joueur</th>
        <th>Rapport</th>
        <th>Date</th>
        <th>Jugement</th>
    </tr>
  </thead>
  <tbody>
    <tr ng-repeat="item in reportTribu">
        <td><a href="#/user/{{item.steamid}}">{{item.name}}</a></td>
        <td><a href="#/tribunal/case/{{item.id}}">{{item.report_raison}}</a></td>
        <td>{{item.timestamp*1000 | date}}</td>
        <td>
          <span class="label label-danger" ng-show="item.jail>0 || item.amende>0">Condamné</span>
          <span class="label label-success" ng-show="item.jail==0 && item.amende==0">Acquitté</span>
          <span class="label label-warning" ng-show="item.jail==-1 && item.amende==-1">En cours</span>

          <span ng-show="item.jail>0 || item.amende>0">à {{item.jail}} heures et {{item.amende}}$</span> par <a href="#/tribunal/case/{{item.juge}}">{{item.jugeName}}</a>
        </td>
    </tr>
  </tbody>
</table>
