<link rel="stylesheet" type="text/css" href="/css/wiki/wiki.css" media="screen">
<script type="text/javascript" src="/js/wiki/wiki.js"></script>

<style>
.PCwrapper {
	position: relative;
	background: url(/images/pattern.png) repeat;
	width: 110px;
	height: 110px;
	border: 1px solid #aaa;
	border-radius: 100%;
	margin-left:90px;
	margin-top: 10px;
}
.PCwrapper, .PCwrapper * {
	-moz-box-sizing: border-box;
	-webkit-box-sizing: border-box;
	box-sizing: border-box;
}
.PCwrapper .pie {
	width: 50%;
	height: 100%;
	transform-origin: 100% 50%;
	position: absolute;
	background: #aaa;
}
.PCwrapper .spinner {
	border-radius: 100% 0 0 100% / 50% 0 0 50%;
	z-index: 200;
}
.PCwrapper .filler {
	border-radius: 0 100% 100% 0 / 0 50% 50% 0;
	left: 50%;
	opacity: 0;
	z-index: 100;
}
.PCwrapper .mask {
	width: 50%;
	height: 100%;
	position: absolute;
	background: inherit;
	opacity: 1;
	z-index: 300;
	border-radius: 100% 0 0 100% / 50% 0 0 50%;
}
</style>

<div ng-controller="ctrlAide" id="mainWiki">

<br /><br />

	<nav class="navbar navbar-inverse p-navbar hidden-phone hidden-sm" id="mw-navigation" style="height: 58px;">
		<div class="container-fluid">
			<div class="navbar-header">
				<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#mw-navigation-collapse" aria-expanded="false">
					<span class="sr-only">Toggle navigation</span>
					<span class="icon-bar"></span><span class="icon-bar"></span><span class="icon-bar"></span>
				</button>
				<!-- logo and main page link -->
				<div id="p-logo" class="p-logo navbar-brand" role="banner">
					<a href="/index.php?page=aide" title="Page principale"><img src="/w/images/b/bc/Wiki.png" class="img_wiki_menu" width="40" height="40" alt="ts-X.eu :: wiki"></a>
				</div>
			</div>
			<div class="navbar-collapse collapse" id="mw-navigation-collapse" aria-expanded="false" style="height: 0px;"><ul class="nav navbar-nav">
				<!-- navigation -->
				<li id="n-mainpage-description"><a href="/index.php?page=aide" title="Aller à l'accueil [alt-shift-z]" accesskey="z">Accueil</a></li>
					<!-- Rôle-Play -->
					<li class="dropdown">
						<a href="#" class="dropdown-toggle" data-toggle="dropdown">Rôle-Play <b class="caret"></b></a>
							<ul class="dropdown-menu p-Rôle-Play" id="p-Rôle-Play">
								<li><a href="/index.php?page=aide&sub=debuter"><i class="fa fa-book" aria-hidden="true"></i> Comment bien débuter ?</a></li>
								<li><a href="/index.php?page=aide&sub=argent"><i class="fa fa-money" aria-hidden="true"></i> Comment gagner de l'argent sur le Roleplay ?</a></li>
								<li><a href="/index.php?page=aide&sub=emploi"><i class="fa fa-map-o" aria-hidden="true"></i> Comment Trouver un emploi ?</a></li>
								<li><a href="/index.php?page=aide&sub=debuter#GroupD"><i class="fa fa-heart" aria-hidden="true"></i> Le Mariage [☻CREA☻]</a></li>
								<li><a href="/index.php?page=aide&sub=pvp"><i class="fa fa-shield" aria-hidden="true"></i> La PvP</a></li>
								<li><a href="/index.php?page=aide&sub=mairie"><i class="fa fa-medium" aria-hidden="true"></i> La Mairie</a></li>
								<li><a href="/index.php?page=aide&sub=crayon"><i class="fa fa-paint-brush" aria-hidden="true"></i> Les Crayons de Couleurs</a></li>
								<li><a href="/index.php?page=aide&sub=argent#GroupE"><i class="fa fa-users" aria-hidden="true"></i> Le Parrainage </a></li>
						</ul>
					</li>
					<!-- Nouveaux Joueurs -->
					<li class="dropdown">
						<a href="#" class="dropdown-toggle" data-toggle="dropdown">Administration <b class="caret"></b></a>
						<ul class="dropdown-menu dropdown-menu-inverse p-Nouveaux Joueurs" id="p-Nouveaux Joueurs">
							<li><a href="https://www.ts-x.eu/forum/viewtopic.php?f=10&t=26749"><i class="fa fa-university" aria-hidden="true"></i> Le Règlement Général</a></li>
							<li><a href="/index.php?page=aide&sub=nopyj"><i class="fa fa-graduation-cap" aria-hidden="true"></i> Le rang no-pyj </a></li>
							<li><a href="/index.php?page=aide&sub=emploi#GroupE"><i class="fa fa-user-secret" aria-hidden="true"></i> Devenir Chef d'un métier</a></li>
							<li><a href="/index.php?page=aide&sub=admin#GroupB"><i class="fa fa-user-plus" aria-hidden="true"></i> Les référés</a></li>
							<li><a href="/index.php?page=aide&sub=admin#GroupA"><i class="fa fa-coffee" aria-hidden="true"></i> Qui sont les Ts-X</a></li>
							<li><a href="/index.php?page=aide&sub=admin#GroupC"><i class="fa fa-wheelchair" aria-hidden="true"></i> Passer VIP</a></li>
							<li><a href="/index.php?page=aide&sub=admin#GroupD"><i class="fa fa-rebel" aria-hidden="true"></i> Devenir membre CS:GO</a></li>
						</ul>
					</li>
						<!-- Informations Pratiques -->
					<li class="dropdown">
						<a href="#" class="dropdown-toggle" data-toggle="dropdown">Aide<b class="caret"></b></a>
						<ul class="dropdown-menu p-Informations Pratiques" id="p-Informations Pratiques">
							<li><a href="/index.php?page=aide&sub=debuter#GroupF"><i class="fa fa-headphones" aria-hidden="true"></i> Le TeamSpeak [TS]</a></li>
							<li><a href="/index.php?page=aide&sub=bind"><i class="fa fa-keyboard-o" aria-hidden="true"></i> Mettre en place vos binds</a></li>
							<li><a href="/index.php?page=aide&sub=record"><i class="fa fa-video-camera" aria-hidden="true"></i> Comment faire une record ?</a></li>
							<li><a href="https://www.ts-x.eu/index.php?page=iframe#/DevZone/" rel="nofollow"><i class="fa fa-ticket" aria-hidden="true"></i> Les futures mises à jours</a></li>
							<li><a href="/index.php?page=aide&sub=help"><i class="fa fa-bug" aria-hidden="true"></i> Bugs et Problèmes connus </a></li>
							<li><a href="https://www.ts-x.eu/forum/viewtopic.php?f=10&amp;t=28678&amp;view=unread#unread" rel="nofollow"><i class="fa fa-check" aria-hidden="true"></i> Mises à jours effectuées</a></li>
						</ul>
					</li>
					<!-- Outils -->
					<li class="dropdown">
						<a href="#" class="dropdown-toggle" data-toggle="dropdown">Outils <b class="caret"></b></a>
						<ul class="dropdown-menu p-Outils" id="p-Outils">
							<li><a target="_blank" href="/web/messorem/images/"><i class="fa fa-cloud-upload" aria-hidden="true"></i> Importer une image</a></li>
							<li><a target="_blank" href="https://github.com/ts-x/TSX-WEB/tree/master/templates/tpl/aide"><i class="fa fa-cog" aria-hidden="true"></i> Modifier le Wiki</a></li>
							<li><a target="_blank" href="https://www.ts-x.eu/forum/viewtopic.php?f=10&t=33820&view=unread#unread"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> Signaler un problème</a></li>
							<li><a href="/index.php?page=aide&sub=vip"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> Beta VIP</a></li>
						</ul>
					</li>
				</ul>


				<div ng-controller="search" class="pull-right" style="margin-top: 10px;">
					<input class="form-control" type="text" placeholder="Rechercher" ng-model="search" />
					<ul>
						<li ng-repeat="item in data"><a href="index.php?page=aide&sub={{item.ref}}">{{item.ref}}</a></li>
					</ul>
				</div>

				</div><!-- /.navbar-collapse -->
			</div>
		</div>
	</nav>
					<div class="hidden-sm hidden-md hidden-lg alert alert-danger" role="alert"><br />
					  <span><img alt="attention" id="img_warning" src="/images/wiki/warning.png"/></span>
					  Vous êtes actuellement sur une Version Beta du mode téléphone.
					</div>
