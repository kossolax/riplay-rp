<!DOCTYPE html>
<html lang="fr" xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta charset="utf-8" />
	
	<title>.:|ts-X|:. {titre} </title>
	
	<link rel="icon" type="image/png" href="/images/icons/favicon.png" />	
	<link rel="stylesheet" media="screen" href="/forum/styles/hermes/theme/stylesheet.css" type="text/css" />
	<link rel="stylesheet" media="screen" href="/css/stylesheet.css"  type="text/css" />
	<link rel="stylesheet" media="screen" href="/css/styles_CONFIG.css" type="text/css" />
	<link rel="stylesheet" media="screen" href="/css/styles_{color}.css" type="text/css" />
	<link rel="stylesheet" media="screen" href="/css/jquery-ui.min.css" />

	<script type="text/javascript" src="/js/jquery-2.0.3.min.js"></script>



	<script type="text/javascript" src="/js/snow.js"></script>

	<script type="text/javascript" src="/js/swfobject.js"></script>
	<script type="text/javascript" src="/js/superfish.js"></script>

	<script type="text/javascript">
		$(document).ready(function() { 
			$('ul.sf-menu').superfish({
				delay:       750,
				animation:   {opacity:'show',height:'show'},
				speed:       'fast',
				autoArrows:  false,
				dropShadows: false
			});
			var Snow = new CSnow( $('#logo'), false );	
		});

		var g_Login_USERID = {userid};
		var g_Login_STEAMID = "{steamid}";
	</script>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

ga('create', 'UA-32533306-1', 'ts-x.eu');
ga('send', 'pageview');
ga('set', '&uid', {userid});

</script>
</head>
<body>
	<div id="header">
		<div id="logo" style="background-image:url('/images/logo/{color}.png'); height:100px; background-repeat:no-repeat; background-position:center;">
<!--
			<div style="float:left;"><a href="http://www.ts-x.eu/index.php?page=live"><img src="http://cdn.bulbagarden.net/upload/8/88/Spr_2c_094.gif" /></a></div>
-->
			<a style="display:block; width:50%; height:100px; margin:auto;" href="index.php"></a>
			<div style="float:right; margin-top:-100px; text-align:right;" class="right">
				<a style="z-index:5000000;" href="javascript:%20(function%20()%20{%20if%20(window.goggles%20&amp;&amp;%20window.goggles.active)%20{%20window.goggles.stop();%20}%20else%20{%20window.GOGGLE_SERVER='//goggles.sneakygcr.net/page';%20var%20scr%20=%20document.createElement('script');%20scr.type%20=%20'text/javascript';%20scr.src%20=%20'//goggles.sneakygcr.net/bookmarklet.js?rand='+Math.random();%20document.documentElement.appendChild(scr);%20}%20})();">
					<img src="/images/icons/Paint_Windows_7_icon.png" height="20" />
				</a>
				<a href="/index.php?color=RED" class="Red_ColorConfig">&#x25cf;</a>
				<a href="/index.php?color=GREEN" class="Green_ColorConfig">&#x25cf;</a>
				<a href="/index.php?color=BLUE" class="Blue_ColorConfig">&#x25cf;</a>
				<a href="/index.php?color=ROSE" class="Rose_ColorConfig">&#x25cf;</a>
				<a href="/index.php?color=ORANGE" class="Orange_ColorConfig">&#x25cf;</a>
				<a href="/index.php?color=GRAY" class="Gray_ColorConfig">&#x25cf;</a>
			</div>
			<div style="float:right; margin-top:-20px; text-align:right;" class="right">
				<a href="#">{player_count} joueurs connectés</a>
			</div>
		</div>
		<div id="navbar">
			<div id="navbar-sub">
				<ul class="sf-menu">
					<li><a href="/index.php" {location_site}>Le Site</a>
						<ul>
							<li><a href="/index.php">News</a></li>
							<li><a href="/forum/memberlist.php?mode=group&amp;g=19">La Team</a></li>
							<li><a href="#">MultiMedia</a>
								<ul>
									<li><a href="/index.php?page=upload">Envois</a></li>
									<li><a href="/index.php?page=download">T&eacute;l&eacute;chargement</a></li>
								</ul>
							</li>
							<li><a href="/index.php?page=steam">Outils Steam</a>
								<ul>
									<li><a href="/index.php?page=valider_steamid">Modifier son SteamID</a></li>
									<li><a href="/index.php?page=steam">Convertir un SteamID</a></li>
								</ul>
							</li>
							<li><a href="/index.php?page=money">Achat de $RP</a></li>
							<li><a href="/forum/viewtopic.php?p=420314#p420314">Info DDoS</a></li>
							<li><a href="/panel.php?page=index">Panel Admin</a></li>
						</ul>
					</li>
					<li><a href="#" {location_roleplay}>RolePlay</a>
						<ul>
							<li><a href="/wiki/">Besoin d'aide? (WiKi)</a></li>
							<li><a href="/forum/viewtopic.php?f=10&amp;t=26749">R&egrave;glement g&eacute;n&eacute;ral</a></li>
							<li><a href="/index.php?page=roleplay&amp;game=csgo">Liste des jobs</a></li>
							<li><a href="/index.php?page=rank">Le classement RP</a>
								<ul>
									<li><a href="/index.php?page=rank">Général</a></li>
									<li><a href="/index.php?page=rank&amp;type=money">Richesse</a></li>
									<li><a href="/index.php?page=rank&amp;type=sell">Ventes</a></li>
									<li><a href="/index.php?page=rank&amp;type=buy">Achats</a></li>
									<li><a href="/index.php?page=rank&amp;type=age">Ancienneté</a></li>
									<li><a href="/index.php?page=rank&amp;type=vital">Vitalité</a></li>
									<li><a href="/index.php?page=rank&amp;type=parrain">Parrainage</a></li>
									<li><a href="/index.php?page=rank&amp;type=pvp">PvP</a></li>
									<li><a href="/index.php?page=roleplay&amp;sub=CAPITAL&amp;game=csgo">Capitaux</a></li>
								</ul>
							</li>
							<li><a href="/index.php?page=success">Les succ&egrave;s</a></li>
							<li><a href="/index.php?page=parrainage">Parrainage</a></li>
							<li><a href="/index.php?page=tribunal&amp;action=report">Le Tribunal</a></li>
							<li><a href="/index.php?page=money">Achat de $RP</a></li>
						</ul>
					</li>
					<li><a href="/forum/index.php" {location_forum}>Forum</a>
						<ul>
							<li><a href="/forum/index.php">Toutes les cat&eacute;gories</a></li>
							<li><a href="/forum/viewforum.php?f=92">Section g&eacute;n&eacute;rale</a></li>
							<li><a href="/forum/viewforum.php?f=117"><img src="/images/icons/section/2.png" width="16" height="16" alt="" /> RolePlay </a></li>
							<li><a href="/forum/viewforum.php?f=88"><img src="/images/icons/section/3.png" width="16" height="16" alt=""/> League Of Legend</a></li>
							<li><a href="/forum/viewforum.php?f=83"><img src="/images/icons/section/4.png" width="16" height="16" alt="" /> Team Fortress 2</a></li>
							<li><a href="/forum/viewforum.php?f=20"><img src="/images/icons/section/1.png" width="16" height="16" alt="" /> Priv&eacute;e</a></li>
							<li><a href="/forum/ucp.php?mode=login"><img src="/images/icons/lock.gif" width="16" height="16" alt="" /> Connexion </a></li>
						</ul>
					</li>
					<li><a href="/wiki/" {location_serveur}><span style="font-size:18px;">WiKi</span></a>
						<ul>
							<li><a href="/index.php?page=serveurs">Info Serveurs</a></li>
							<li><a href="/index.php?page=skillrank">Skill-Rank</a></li>
							<li><a href="/index.php?page=bannis">Les bannis</a></li>
							<li><a href="/index.php?page=irc">IRC</a></li>
						</ul>
					</li>
					<li><a href="ts3server://ts.ts-x.eu/?port=9987">TeamSpeak</a></li>
				</ul>
			</div>
		</div>
	</div>
	<div id="page" class="clearfix">
		<br clear="all" />
		{page}
		<br clear="all" />
	</div>
        <div id="footer">
                <div style="text-align:center;">
                        Copyright &copy; .:|ts-X|:. team &nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;
			<a href="http://www.ts-x.eu/">www.ts-x.eu</a> &nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;
			<a href="http://m.ts-x.eu"> Version mobile </a> &nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;
                        Heure du serveur: <span class="ServerTime">{timestamp}</span> &nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;
                        by KoSSoLaX`
                </div>
                <br clear="all" />
        </div>

        <script type="text/javascript" src="/js/globals.js"></script>
        <script type="text/javascript" src="/js/upload.js"></script>
        <script type="text/javascript" src="/js/axah.js"></script>
        <script type="text/javascript" src="/js/steam.js"></script>
        <script type="text/javascript" src="/js/forum.js"></script>
        <script type="text/javascript" src="/js/admin.js?v=2"></script>
	  
        <script type="text/javascript" src="/js/jquery-ui.min.js"></script>
        <script type="text/javascript" src="/js/jquery.cookie.js"></script>
        <script type="text/javascript" src="/js/jquery.progressbar.min.js"></script>
        <script type="text/javascript" src="/js/jquery-ui-timepicker-addon.min.js"></script>
        <script type="text/javascript" src="/js/jquery.mousewheel.min.js"></script>
        <script type="text/javascript" src="/js/jquery.gracefulWebSocket.js"></script>
        <script type="text/javascript" src="/js/jquery.flot.min.js"></script>
        <script type="text/javascript" src="/js/curvedLines.js"></script>
	<script type="text/javascript" src="/js/jquery.flot.pie.js"></script>
</body>
</html>
