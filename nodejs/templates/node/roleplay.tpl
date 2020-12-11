
<div class="row">
  <div class="col-md-8">
    <h2>Il est {{stats.time.h}}h{{stats.time.m}} sur le serveur roleplay</h2>
  </div>
  <div class="col-md-4 text-right">
    <h3><br />
      Prochaine pvp: <span class="text-success">{{pvp | date : 'dd/MM à HH:mm'}}</span><br /><br />

      <div ng-show="bf">
        Le BLACK FRIDAY <span class="text-success">-{{reduction}}%</span> prend fin dans <span class="text-success">{{ calcEnd.hour}} heure(s) {{ calcEnd.min}} minute(s) {{ calcEnd.sec }} seconde(s)</span><br><br />
      </div>

      Cagnotte: {{stats.cagnotte[0] | currency : '' : 0}}$ <sub>{{stats.cagnotte[1] | currency : '' : 0}}$ <sub>{{stats.cagnotte[2] | currency : '' : 0}}$</sub></sub></h3>
  </div>
</div>
<br clear="all" />


<div class="btn-group btn-group-justified">
  <a class="col-md-3 col-sm-6 btn btn-default" href="#/search" >
    <img class="pull-left img-circle" width="64" height="64" src="/images/icons/search.jpg" />
    <div><strong>Recherche</strong><br />par pseudo, job</div>
  </a>
  <a class="col-md-3 col-sm-6 btn btn-default" href="#/map" >
    <img class="pull-left img-circle" width="64" height="64" src="/images/icons/map.jpg" />
    <div><strong>La carte</strong><br />vue satellite</div>
  </a>
  <a class="col-md-3 col-sm-6 btn btn-default" href="#/craft/0" >
    <img class="pull-left img-circle" width="64" height="64" src="/images/icons/map.jpg" />
    <div><strong>Les craft</strong><br />et les maitrises</div>
  </a>
  <a class="col-md-3 col-sm-6 btn btn-default" href="#/graph/0" >
    <img class="pull-left img-circle" width="64" height="64" src="/images/icons/nuke.jpg" />
    <div><strong>Graphique</strong><br />Des meilleurs jobs</div>
  </a>
  <a class="col-md-3 col-sm-6 btn btn-default" href="#/tribunal/report" >
    <img class="pull-left img-circle" width="64" height="64" src="/images/icons/report.jpg" />
    <div><strong>Rapporter</strong><br />Un mauvais comportement</div>
  </a>
</div>
<br clear="all" /><br clear="all" />
<h3>Informations:</h3>
<div class="btn-group btn-group-justified">
  <a class="col-md-3 col-sm-6 btn btn-default" ng-repeat="(key, value) in stats.pvp" ng-attr-href="{{key!='bunker' ? '#/user/'+value.id+'' : '#/group/'+value.id+''}}" href="yo">
    <img class="pull-left img-circle" width="128" height="64" src="/images/icons/{{key}}.jpg" />
    <div>
      <strong>{{value.type}}:</strong><br />{{value.nom}}
    </div>
  </a>
</div>
<br clear="all" /><br clear="all" />
<h3>Le meilleur de chaque classement:</h3>
<div class="btn-group">
  <a class="col-md-3 col-sm-6 btn btn-default" ng-repeat="(key, value) in stats.stats" href="#/rank/{{key}}">
    <img class="pull-left img-circle" width="64" height="64" src="/images/icons/{{key}}.jpg" />
    <div ng-class="(key=='freekill'||key=='freekill2'?'text-warning':'')">
      <strong>{{value.type}}:</strong><br />{{value.name}}<sub ng-show="key=='freekill'||key=='freekill2'"><br />Il n'est pas recommandé d'être premier</sub>
    </div>
  </a>
</div>
<br clear="all" /><br clear="all" />
