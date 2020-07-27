<h2>Les dernières mises à jour</h2>
<div ng-hide="data" class="text-center"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-{{i}}x"></i></div>
<table class="table">
  <thead>
    <tr><th>Auteur</th><th>Commentaire</th><th>Fichiers</th><th width="100">Date</th></tr>
  </thead>
  <tbody>
    <tr ng-repeat="i in data"><td>{{i.author}}</td><td>{{i.message}}</td><td>{{i.files}} ({{i.changes}} lignes)</td><td>{{i.date | date}}</td></tr>
  </tbody>
</table>
