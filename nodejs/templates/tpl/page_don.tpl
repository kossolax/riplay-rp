<div class="row clearfix">
<h2 class="ThemeLettre">Achat de $RP:</h2>

	{if="$lastMonth"}
<div class="alert alert-dismissable alert-success">
	<h4>Merci!</h4>	 Vous étiez dans le top10 donateur le moi pr&eacute;c&eacute;dant et nous vous en remercions infiniment.
	Grâce &agrave; vous, nous pouvons assurer tous les jours d'avoir un serveur de qualit&eacute; et r&eacute;sistant contre les diverses attaques DDoS
	que nous subissons tous les jours.<br />
	Afin de vous remercier, connectez vous sur notre serveur puis <a href="/index.php?page=money&action=lastMonth">cliquer ici</a> pour obtenir la voiture r&eacute;serv&eacute;e aux donateurs.
</div>
	{/if}

	<div class="col-md-8 col-md-offset-2">
		<p class="ThemeLettre">
			Vous souhaitez aider financi&egrave;rement le serveur?
			Vous le pouvez, et c'est tout &agrave; votre avantage!<br />
			Les donateurs sont un réel soutien pour le serveur,
			ainsi nous vous offrons une somme d'argent sur le Roleplay CS:GO
			proportionnelle aux dons que vous nous faites. <a href="/forum/viewtopic.php?f=178&t=36325">Les bonus des serveurs TF2 sont expliqués ici.</a>
			<br /><br />
			Votre soutien compte beaucoup pour nous, c'est pourquoi, chaque donateur reçoit un grade
			sur le forum dans l'objectif d'être dicerné des autres.	Ainsi nous pouvons mieux
			être à votre écoute pendant 1 mois après votre achat.
			Les meilleurs donateurs sont aussi récompensés par un skin unique sur notre serveur pour
			les mêmes raisons: C'est une façon d'inter-agir avec un
			    niveau d’écoute plus élevé qu'avec les autres joueurs.
			   <br /><br />

		        Coût de nos serveurs: 120&euro;. {if="$objectif>120"} C'est payé, merci !{else}<img src="//www.ts-x.eu/images/grad.php?per={$objectif/120*100}&text={$objectif|floor} / 120&hex=00498c" />{/if}<br />
			Pourquoi nos serveurs coûtent si cher? Nous souhaitons une qualité de jeu irréprochable. C'est pourquoi nous avons du matériel haute gamme et des serveurs très puissant.
			Nous mettons aussi l'accent sur l'impossibilité de nous DDoS. Mais cela a un prix...
			<br /><br />
		</p>
	</div>
	<div class="col-md-12" ng-init="paysafecard=0; paypal=1; starpass=1; steam=1">
		<div class="btn-group btn-group-justified col-md-8">
		  <a class="col-md-3 btn btn-default" ng-click="paysafecard=0; paypal=0; starpass=0; steam=0">
		    <img src="/images/paysafecard.png" style="max-width:100%">
		  </a>
{if="$simple == 0"}
		  <a class="col-md-3 btn btn-default" ng-click="paysafecard=0; paypal=1; starpass=0; steam=0">
		  	<img src="/images/paypal.png" style="max-width:100%">
		  </a>
{/if}
		  <a class="col-md-3 btn btn-default" ng-click="paysafecard=0; paypal=0; starpass=1; steam=0">
		    <img src="/images/starpass.png" style="max-width:100%">
		  </a>
			<a class="col-md-3 btn btn-default" ng-click="paysafecard=0; paypal=0; starpass=0; steam=1">
		    <img src="/images/steam.png" style="max-width:100%">
		  </a>
		</div>
	</div>

	<div class="col-md-8 col-md-offset-2" >
		<div class="row" ng-show="paysafecard" >
			<h3>PaySafeCard:</h3>
			<p>
				Traitement dans les 5 minutes en journée (12 heures maximum).
				Les PaySafeCard JUNIOR ne sont pas acceptées. Uniquement France/Belgique.
				<img src="/images/paysafecard.png" width="200" class="pull-right"/>
			</p>
			<br clear="all" />
			<form action="index.php?page=money&paysafecard=1" method="POST">
				<div class="form-group">
					<label class="col-sm-3 control-label" for="textinput">Code:</label>
					<div class="col-sm-7">
						<input autocomplete="off" name="code" placeholder="xxxx-xxxx-xxxx-xxxx" class="form-control input-sm" required="required" />
					</div>
				</div>
				<div class="form-group">
					<label class="col-sm-3 control-label">Montant:</label>
					<div class="col-sm-7">
							<input autocomplete="off" class="form-control" type="number" name="amount" value="{{ppAmount}}" ng-init="ppAmount=20" ng-model="ppAmount" min="1" ng-min="1"/>
					</div>
				</div>
				<div class="col-sm-7 col-sm-offset-3">
					<input class="form-control" type="submit" value="Envoyer {{ppAmount}}€ pour recevoir {{ppAmount*25000*0.94}} $RP" />
				</div>
			</form>
		</div>
{if="$simple == 0"}
		<div class="row" ng-show="paypal">
			<h3>PayPal:</h3>
			<p>
				La validation s'effectue automatiquement à la fin de votre paiement.
				Cependant, des vérifications sur votre identité peuvent vous-être demandée afin de vérifier que vous êtes bien
				le propriétaire de votre compte PayPal.
				<img src="/images/paypal.png" width="200" class="pull-right" />
			</p>
			<br clear="all" />
			<form id="ppBtnForm" action="https://www.paypal.com/cgi-bin/webscr" method="POST">
				<input type="hidden" name="cbt" value="">
				<input type="hidden" name="cmd" value="_xclick">
				<input type="hidden" name="receiver_email" value="paypal@ts-x.eu">
				<input type="hidden" name="business" value="paypal@ts-x.eu">
				<input type="hidden" name="quantity" value="1">
				<input type="hidden" name="item_name" value="Achat de {{ppAmount*25000*0.966-3500}}$RP">
				<div class="form-group">
					<label class="col-sm-3 control-label">Montant:</label>
					<div class="col-sm-7">
							<input autocomplete="off" class="form-control" type="number" name="amount" value="{{ppAmount}}" ng-model="ppAmount" min="1" ng-min="1"/>
					</div>
				</div>
				<div class="col-sm-7 col-sm-offset-3">
					<input class="form-control" type="submit" value="Envoyer {{ppAmount}}€ pour recevoir {{ppAmount*25000*0.966-3500}} $RP" />
				</div>
				<input type="hidden" name="return" value="https://www.ts-x.eu/index.php?page=money&paypal_done=1">
				<input type="hidden" name="cancel_return" value="https://www.ts-x.eu/index.php?page=money&paypal_cancel=1">
				<input type="hidden" name="on1" value="SteamID">
				<input type="hidden" name="os1" maxlength="200" value="{$steamid}">
				<input type="hidden" name="notify_url" value="https://www.ts-x.eu/paypal.php">
				<input type="hidden" name="currency_code" value="EUR">
				<input type="hidden" name="lc" value="FR">
			</form>
		</div>
{/if}
		<div class="row" ng-show="starpass">
			<h3>StarPass:</h3>
			<p class="text-center">1 Code = 37 500$RP.</p>
			<div id="starpass_14466"></div>
		</div>
		<div class="row" ng-show="steam" ng-app="appTrade" ng-controller="ctrlTrade">
			<h3>Steam Trade:</h3> Attention, les prix des skins affichés en $RP incluent les frais lié à transaction sur le marché.
			  <div class="col-sm-12 alert alert-info">
				<strong>Nouveau!</strong> Pour envoyer très facilement plusieurs items en un seul échange, contactez KoSSoLaX` sur TeamSpeak afin d'obtenir les explications.
	 		  </div>
			  <div ng-show="doing.length >= 1" class="col-sm-12 alert alert-warning" role="alert">
			    <strong>Vous avez toujours des transactions en attente</strong> <a href="https://steamcommunity.com/my/tradeoffers/">Veuillez les confirmer</a>.
			  </div>
			  <div ng-show="doing.length >= 1" class="col-sm-12">
			    <figure class="img-polaroid col-md-3" ng-repeat="item in doing" style="height:160px;float:left;text-align:center;">
			      <strong ng-show="item.escrow">Cette transaction est bloquée par Steam jusqu'au {{item.escrow | date:"dd/MM à HH:mm"}}<br /></strong>
			      {{item.name}}
			        <br /><br />
			        <a href="https://steamcommunity.com/my/tradeoffers/{{item.id}}"><img src="http://steamcommunity-a.akamaihd.net/economy/image/{{item.image}}" width="100" /></a>
			        <br />
				<span style="text-decoration: line-through">{{item.price*0.95*25000 | number: 0 }}$RP</span><span class="text-info">{{item.price * 0.95 * 25000 | number: 0}}$RP</span>
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
			    <h3>Votre inventaire échangable</h3>
			    <figure class="img-polaroid col-md-3" ng-repeat="item in items" style="height:150px;float:left;text-align:center;">
			        {{item.name}}
			        <br />
			        <img src="http://steamcommunity-a.akamaihd.net/economy/image/{{item.image}}" width="100" height="100" ng-click="offert(item.id)" style="cursor: pointer;"/>
			        <br />
			        <span class="text-info">{{item.price * 0.95 | number: 2}}€</span>
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
			    <strong>Notre bot est hors ligne?</strong> Impossible de valider votre transaction pour le moment. Soit notre bot <a href="http://steamcommunity.com/id/ts-x/">est hors ligne</a>, soit il y a un souci technique. Si le problème persiste, contactez KoSSoLaX` sur TeamSpeak ou par email à kossolax@ts-x.eu
			  </div>
			  <div ng-show="state == 6" class="col-sm-12 alert alert-danger" role="alert">
			    <strong>Erreur</strong> Vous avez trop de transactions non validées. <a href="https://steamcommunity.com/my/tradeoffers/">Veuillez les confirmer ou les refuser</a>.
			  </div>
		</div>
	</div>
</div>
<div class="row clearfix">
	<h2>Top 10 ce mois:</h2>
	<div class="col-md-8 col-md-offset-2">
		<div class="col-sm-7">
			<p>Être dans ce classement, vous honore. C'est pourquoi nous vous offrons un skin unique sur le serveur tant que vous êtes dans ce classement.
			De plus, à la fin du mois. vous recevrez une voiture unique sur le serveur. L'entrée du classement ce-mois ci est à {$inTop10}€, ou {$inTop10RP|pretty_number}$RP reçu. </p>
			<ol>
				{loop="$top10"}
					{if="$key<=10"}
						<li>{$value.uname2}</li>
					{/if}
				{/loop}
			</op>
		</div>
		<div class="col-sm-3">
			<a class="various" href="/images/donateurgift.jpg">
				<img src="/images/donateurgift.jpg" class="img-polaroid" class="pull-right" />
			</a>
		</div>

	</div>
</div>
<br />

<script type="text/javascript">
	$(window).load( function() {
		$.getScript( "https://script.starpass.fr/script.php?idd=14466&verif_en_php=1&datas=&theme=dark_grey_small&last=1" );
	});

	var app = angular.module("tsx", [], function ($compileProvider) {
	  $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|steam):/);

	});
	app.controller('ctrlTrade', function($scope, $http, $filter, $location) {
	  $http.defaults.headers.common['auth'] = _md5;
	  $scope.steamid = _steamid;
	  $scope.state = 0;
	  $scope.link = "{$link}";
	  $scope.validLink = false;
	  $scope.patternLink = new RegExp(/^https:\/\/steamcommunity\.com\/tradeoffer\/new\/\?partner=([0-9]+)&token=([a-zA-Z0-9_-]+)$/);
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
	      }).error(function(res) { $scope.state = 5; console.log(res); });
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
