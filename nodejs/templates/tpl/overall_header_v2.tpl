<!DOCTYPE html>
<html lang="fr" ng-app="tsx">
<head>
	<title>.:|ts-X|:. {$titre} </title>
	<meta charset="utf-8">
	<link rel="icon" type="image/png" href="/images/logo.png" />
	<meta name="description" content="site web de la team .:|ts-x|:.">
	<meta name="keywords" content="ts-x.eu roleplay csgo css kossolax bajail rp-csgo rp-css rp">
	<meta name="author" content="kossolax">
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<meta property="og:image" content="/images/ts.png" />

	<link rel="stylesheet" type="text/css" href="/css/bootstrap.min.css" media="screen">
	<link rel="stylesheet" type="text/css" href="/css/styles.css" media="screen">
	<link rel="stylesheet" type="text/css" href="/css/font-awesome.min.css" media="screen, projection" />

	<script type="text/javascript" src="/js/compile-jquery.2.1.3.min-angular.min.js"></script>

	<!--[if lt IE 9]>
	<link rel="stylesheet" href="/css/ie.css" type="text/css" media="screen">
	<script src="//html5shim.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->
	{if="count($scripts)>0"}<script type="text/javascript" src="/js/compile{loop="$scripts"}-{$value}{/loop}.js"></script>{/if}
	<!-- <style>.subforum,.btn-group-justified, img,.pagination,.postprofile dd,object,embed,.fb-post { transform: rotate(180deg); }.navbar-holder > ul > li { transform: rotate(180deg); } .subforum, .btn-group-justified, dl.icon { transform: scaleY(-1);  }dl.icon dt { transform: scaleY(-1);  }.buttons,.panel-icon,.panel-icon+a,.sf-menu>li { transform: scaleX(-1);  }</style> --> 
	<script type="text/javascript">_app = angular.module("tsx", []); _md5 = '{$uid}'; _steamid = '{$steamid}';
	_app.config(function($httpProvider) { $httpProvider.defaults.headers.common['auth'] = _md5; }); </script>
</head>
<body>
	<header>
		<div class="follow-panel">
			<div class="container">
				<ul class="login">
					{if="$USER.user_id>1"}
						<li><a href="/forum/ucp.php?i=pm&amp;folder=inbox">Bienvenue  {$USER.username}</a></li>
					{elseif="strlen($username)>1"}
						<li><a href="/forum/ucp.php?i=pm&amp;folder=inbox">Bienvenue  {$username}</a></li>
					{else}
						<li><a href="/forum/ucp.php?mode=login">Se connecter</a></li>
						<li><a href="/forum/ucp.php?mode=register">Inscription</a></li>
					{/if}
				</ul>
				<ul class="follow-icon">
			             	<li><a target="_blank" href="https://www.youtube.com/channel/UC87KJ_5RVz6SgOzZPqfQJYw"><i class="fa fa-youtube-play"></i></a></li>
					<li><a target="_blank" href="https://www.facebook.com/The-Specialists-X-Roleplay-1405541629728459"><i class="fa fa-facebook"></i></a></li>
					<li><a target="_blank" href="https://twitter.com/KoSSoLaX"><i class="fa fa-twitter"></i></a></li>
					<li><a target="_blank" href="http://steamcommunity.com/groups/TS-X-RP"><i class="fa fa-steam"></i></a></li>
					<li><a href="ts3server://ts.ts-x.eu/?port=9987"><i class="fa fa-microphone"></i> TS</a></li>
					<li><a href="/index.php?page=irc"># irc</a></li>
					<li><a target="_blank" href="https://github.com/ts-x"><i class="fa fa-github"></i></a></li>
				</ul>
			</div>
		</div>
	</header>
	<div id="menu">
		<div class="pattern">
			<div class="container">
				<nav class="navbar navbar-default" role="navigation">
					<div class="navbar-header">
						<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar" style="z-index:1;">
							<span class="sr-only">Toggle navigation</span>
							<span class="icon-bar"></span><span class="icon-bar"></span><span class="icon-bar"></span>
						</button>
						<a class="navbar-brand" href="./"><img src="{if="$alternate"}{$alternate}{else}/images/bleue42.png{/if}" alt="tsX" width="350" height="100" style="max-height:100px !important"/></a>
					</div>
					<div id="navbar" class="navbar-collapse collapse">
					<ul class="nav navbar-nav navbar-right" style="z-index:2;">
							<li class="visible-lg-block"><a href="/index.php">Accueil</a>
							</li><li class="dropdown">
								<a class="hidden-md hidden-lg" href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Le Site <span class="caret"></span></a>
								<a class="hidden-xs hidden-sm" href="/index.php" >Le Site <span class="caret"></span></a>
								<ul class="dropdown-menu">
  									<li><a class="hidden-md hidden-lg" href="/index.php"><i class="fa fa-home"></i> Accueil</a></li>
									<li><a href="/index.php?page=intro&amp;last=news"><i class="fa fa-newspaper-o"></i> News</a></li>
									<li><a href="/forum/memberlist.php?g=19&amp;mode=group&amp;sk=m&amp;sd=a"><i class="fa fa-users"></i> Les membres</a></li>
									<li><a class="hidden-xs" href="/index.php?page=valider_steamid"><i class="fa fa-steam"></i> Modifier son Steam</a></li>
									<li><a href="/index.php?page=money"></a><a href="/index.php?page=serveurs"><i class="fa fa-server"></i> Info-server<span></span></a></li>
									<li><a href="/index.php?page=roleplay2#/pilori/view/{$steamid}"><i class="fa fa-ban"></i> Ban-liste</a></li>
									<li><a href="/index.php?page=money"><i class="fa fa-usd"></i> Achat de $RP</a></li>
								</ul>
							</li>
							<!--<li class="dropdown">
								<a class="hidden-md hidden-lg" href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">RolePlay <span class="caret"></span></a>
								<a class="hidden-xs hidden-sm" href="/index.php?page=roleplay2#/" >RolePlay <span class="caret"></span></a>
								<ul class="dropdown-menu">
									<li><a href="/index.php?page=aide"><i class="fa fa-wikipedia-w"></i> Besoin d'aide?</a></li>
									<li><a href="/forum/viewtopic.php?f=10&amp;t=26749"><i class="fa fa-balance-scale"></i> Règlement général</a></li>
									<li><a href="/index.php?page=roleplay2#/"><i class="fa fa-briefcase"></i> Liste des jobs<span></span></a></li>
									<li><a href="/index.php?page=success"><i class="fa fa-trophy"></i> Les succès</a></li>
									<li><a class="hidden-xs" href="/index.php?page=tribunal"><i class="fa fa-gavel"></i> Le Tribunal</a></li>
									<li><a href="/index.php?page=report"><i class="fa fa-phone"></i> Le téléphone</a></li>
									<li><a href="/index.php?page=parrainage"><i class="fa fa-user-plus"></i> Parrainage</a></li>
									<li><a href="/index.php?page=money"><i class="fa fa-usd"></i> Achat de $RP</a></li>
								</ul>
							</li>
							<li class="dropdown"><a href="/index.php?page=aide">Aide <span class="caret hidden-xs"></span></a>
								<ul class="dropdown-menu">
									<li><a href="/index.php?page=aide&sub=debuter"><i class="fa fa-key"></i> Comment bien débuter?</a></li>
									<li><a href="/index.php?page=aide&sub=emploi"><i class="fa fa-suitcase"></i> Comment trouver un job?</a></li>
									<li><a href="/index.php?page=aide&sub=argent"><i class="fa fa-money"></i> Comment gagner de l'argent?</a></li>
									<li><a href="/index.php?page=aide&sub=bind"><i class="fa fa-keyboard-o"></i> Mettre en place vos binds</a></li>
									<li><a href="/index.php?page=aide&sub=nopyj"><i class="fa fa-ticket"></i> Qu'est-ce que le rang no-pyj ?</a></li>
                                                                        <li><a href="/forum/viewtopic.php?p=640496"><i class="fa fa-flask"></i> Qu'est-ce que l'artisanat ?</a></li>
								</ul>
							</li>-->
							<li class="dropdown">
								<a href="/forum/">FORUM <span class="caret hidden-xs"></span></a>
								<ul class="dropdown-menu">
									<li><a href="/forum/"><i class="fa fa-globe"></i> Toutes les catégories</a></li>
									<li><a href="/forum/viewforum.php?f=92"><i class="fa fa-list-alt"></i> Section Générale</a></li>
									<li><a href="/forum/viewforum.php?f=83"><img src="/images/icons/section/tf.png" width="16" height="16">Team Fortress 2</a></li>
									<li><a href="/forum/viewforum.php?f=88"><img src="/images/icons/section/lol.png" width="16" height="16">League Of Legend</a></li>
									<li><a href="/forum/viewforum.php?f=20"><i class="fa fa-lock"></i> Privée</a></li>
								</ul>
							</li>
						</ul>
					</div>
				</nav>
			</div>
		</div>
	</div>
	{$intro}
	<div class="container main">
		{$page}
