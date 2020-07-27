<div ng-controller="rpSearch">
  <h2>Recherche de SteamID:</h2>
  <p> Vous recherché le steamID d'un joueur? Entrez son pseudo, ou son job</p>
  <br clear="all" />

  <div class="input-group col-sm-10 col-sm-offset-1" >
      <span class="input-group-addon">Pseudo:</span>
      <input type="text" class="form-control" value="" ng-model="search" ng-change="updateSteamID()" >
      <span class="input-group-addon" ng-show="data.length > 0">Trouvé: {{data.length}} résultat</span>
      <span class="input-group-addon" ng-hide="data.length > 0">Aucune correspondance</span>
  </div>
  <table class="table table-hover">
    <thead>
      <tr>
        <th>SteamID</th><th>Pseudo:</th><th>Job:</th><th>Page Steam</th>
      </tr>
    </thead>
    <tbody>
      <tr ng-repeat="item in data">
        <td><a href="#/user/{{item.steamid}}">{{item.steamid}}</a></td><td>{{item.name}}</td><td>{{item.job}}</td><th><a href="http://steamcommunity.com/profiles/{{item.steam64}}">Go</a></th>
      </tr>
    </tbody>
  </table>
</div>
