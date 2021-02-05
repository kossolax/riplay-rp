<script type="text/javascript">
var app = angular.module("tsx", [], function ($compileProvider) {
  $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|steam):/);

});
app.controller('ctrl', function($scope, $http, $filter, $location) {
  $http.defaults.headers.common['auth'] = _md5;
  $scope.steamid = _steamid;
  $scope.state = 0;
  $scope.link = "{$link}";
  $scope.validLink = false;
  $scope.patternLink = new RegExp(/^https:\/\/steamcommunity\.com\/tradeoffer\/new\/\?partner=([0-9]+)&token=([a-zA-Z0-9_]+)$/);
  $scope.steamid64 = steamIDToProfile($scope.steamid);
  $http.get("https://www.ts-x.eu/api/steam/inventory")
    .success(function (response) { $scope.state = 2; $scope.items = response; })
    .error(function() { $scope.state = 1; });
  $http.get("https://www.ts-x.eu/api/steam/trade")
    .success(function (response) { $scope.doing = response; });

  $scope.submitLink = function() {
    var match = $scope.link.match($scope.patternLink);
    $http.put("https://www.ts-x.eu/api/steam/trade", {partner: match[1], tokken: match[2]}).success(function(res) {
      $scope.state = 2;
    });
  }
  $scope.offert = function(id) {
    $scope.state = 0;
    if( $scope.link == "" ) {
      $scope.state = 3;
      return;
    }
    $http.post("https://www.ts-x.eu/api/steam/trade", {itemid: id})
      .success(function(res) {
        if( res.id >= 1 ) {
          $scope.state = 4;
          $scope.transactionID = res.id;
        }
        else if( res.id == -1 )
          $scope.state = 3;
          else if( res.id == -2 )
            $scope.state = 6;
        else
          $scope.state = 5;
      }).error(function(res) { $scope.state = 5; });
  }
});

function steamIDToProfile(steamID) {
  var parts = steamID.split(":");
  var iServer = Number(parts[1]);
  var iAuthID = Number(parts[2]);
  var converted = "76561197960265728"
  var lastIndex = converted.length - 1

  var toAdd = iAuthID * 2 + iServer;
  var toAddString = new String(toAdd)
  var addLastIndex = toAddString.length - 1;

  for(var i=0;i<=addLastIndex;i++) {
      var num = Number(toAddString.charAt(addLastIndex - i));
      var j=lastIndex - i;

      do {
          var num2 = Number(converted.charAt(j));
          var sum = num + num2;

          converted = converted.substr(0,j) + (sum % 10).toString() + converted.substr(j+1);

          num = Math.floor(sum / 10);
          j--;
      } while(num);
  }
  return converted;
}
</script>
<br /><br />
<div class="col-md-10 col-md-offset-1" ng-app="app" ng-controller="ctrl">
  <div ng-show="doing.length >= 1" class="col-sm-12 alert alert-warning" role="alert">
    <strong>Vous avez toujours des transactions en attente</strong> <a href="https://steamcommunity.com/my/tradeoffers/">Veuillez les confirmer</a>.
  </div>
  <div ng-show="doing.length >= 1" class="col-sm-12">
    <figure class="img-polaroid col-md-3" ng-repeat="item in doing" style="height:160px;float:left;text-align:center;">
      <strong ng-show="item.escrow">Cette transaction est bloquée par Steam jusqu'au {{item.escrow | date:"dd/MM à HH:mm"}}<br /></strong>
      {{item.name}}
        <br /><br />
        <a href="https://steamcommunity.com/my/tradeoffers/{{item.id}}"><img src="http://steamcommunity-a.akamaihd.net/economy/image/{{item.image}}" width="100" /></a>
        <br /> {{item.price * 0.9 * 10000 | number: 0}}$RP
    </figure>
    <br clear="all" />
    <hr />
  </div>
  <div ng-show="state == 0" class="col-sm-12 alert alert-warning" role="alert">
    Chargement des données... <i class="fa fa-cog fa-spin fa-fw"></i><i class="fa fa-cog fa-spin fa-fw"></i><i class="fa fa-cog fa-spin fa-fw"></i>
  </div>
  <div ng-show="state == 1" class="col-sm-12 alert alert-danger" role="alert">
    <strong>Votre inventaire est privé.</strong> Vous pouvez modifier les paramètres d'inventaire <a href="http://steamcommunity.com/my/edit/settings" />ici</a>.
      <a href="http://steamcommunity.com/my/edit/settings" /><img src="/images/steam-trade.png" /></a>
  </div>
  <div ng-show="state == 2 && items.length == 0" class="col-sm-12 alert alert-warning" role="alert">
    <strong>Votre inventaire est vide.</strong> Vous n'avez aucun item qui peut-être revendu pour des $RP.
  </div>
  <div ng-show="state == 2 && items.length != 0">
    <h3>Votre inventaire CS:GO</h3>
    <figure class="img-polaroid col-md-3" ng-repeat="item in items" style="height:150px;float:left;text-align:center;">
        {{item.name}}
        <br /><br />
        <img src="http://steamcommunity-a.akamaihd.net/economy/image/{{item.image}}" width="100" ng-click="offert(item.id)" style="cursor: pointer;"/>
        <br /><br />
        {{item.price*0.9*10000 | number: 0 }}$RP
    </figure>
  </div>
  <div ng-show="state == 3" class="col-sm-12 alert alert-danger" role="alert">
    <strong>Il semble avoir un problème avec votre lien d'échange...</strong> Vous pouvez le retrouver <a href="https://steamcommunity.com/my/tradeoffers/privacy#trade_offer_access_url" target="_newtab">ici</a>.
      <a href="https://steamcommunity.com/my/tradeoffers/privacy#trade_offer_access_url" target="_newtab">
        <img src="/images/steam-confirm.png" />
      </a>
      <br />
      <form name="form" class="input-group">
          <input type="text" class="form-control" name="link" ng-model="link" required ng-pattern="patternLink"/>
          <span class="input-group-btn">
            <input type="submit" class="btn btn-default" ng-class="form.link.$valid?'btn-success':'btn-warning disabled'" value="Envoyer" ng-click="submitLink()" />
          </span>
      </form>
  </div>
  <div ng-show="state == 4" class="col-sm-12 alert alert-success" role="alert">
    <strong>L'offre d'échange est prête!</strong> Il ne vous reste qu'à valider l'échange sur steam. Dès que nous avons reçu votre objet, votre argent sera transféré sur votre compte.
    <br />Si vous avez une question, contactez KoSSoLaX` sur TeamSpeak ou par email à kossolax@ts-x.eu<br />
    <a class="btn btn-default pull-right" href="https://steamcommunity.com/tradeoffer/{{transactionID}}"><i class="fa fa-chrome"></i> Navigateur</a>
    <a class="btn btn-default pull-right" href="steam://url/ShowTradeOffer/{{transactionID}}"><i class="fa fa-steam"></i> Steam</a>
  </div>
  <div ng-show="state == 5" class="col-sm-12 alert alert-warning" role="alert">
    <strong>Notre bot est hors ligne</strong> Impossible de valider votre transaction pour le moment. Soit Steam est hors ligne, soit il y a un souci chez nous. Si le problème persiste, contactez KoSSoLaX` sur TeamSpeak ou par email à kossolax@ts-x.eu
  </div>
  <div ng-show="state == 6" class="col-sm-12 alert alert-danger" role="alert">
    <strong>Erreur</strong> Vous avez trop de transactions non validées. <a href="https://steamcommunity.com/my/tradeoffers/">Veuillez les confirmer ou les refuser</a>.
  </div>
</div>
