<div id="slider" class="carousel slide" data-ride="carousel">
	<ol class="carousel-indicators"><li data-target="#slider" data-slide-to="0" class="active"></li><li data-target="#slider" data-slide-to="1"></li><li data-target="#slider" data-slide-to="2"></li><li data-target="#slider" data-slide-to="3"></li></ol>
	<div class="carousel-inner" role="listbox">
		<div class="item active">
			<img alt="PRINCETON" src="/images/princeton{if="$isMobile"}_small{/if}.jpg">
			<div class="flex-caption"><div>
				<p class="title1">Serveur RolePlay</p> <time>CSGO: Princeton <span class="infoServ" data-query="178.32.42.113/27015"></span></time>
				<p class="title2">Qui n'a jamais rêvé d'incarner un autre personnage et de faire ce qu'il veut? Rendez-vous sur le serveur RolePlay CS:GO et commencez dès à présent votre nouvelle vie.</p>
				<a class="various btn btn-primary" href="steam://connect/178.32.42.113:27015/"><i class="fa fa-hand-o-right"></i> Rejoindre</a>
			</div></div>
		</div>
		<div class="item">
			<img alt="SAXTON" src="/images/saxton{if="$isMobile"}_small{/if}.jpg">
			<div class="flex-caption"><div>
				<p class="title1">Serveur SaxtonHale</p> <time>TF2: SaxtonHale <span class="infoServ" data-query="176.31.38.177/27025"></span></time>
				<p class="title2">Le serveur TF2 Saxton-Hale est un mode de jeu "Tous contre un" opposant l'ensemble du serveur contre le Saxton. Un seul joueur pouvant utiliser seulement ses poings et sa force brute afin abattre tout le monde.</p>
				<a class="various btn btn-primary" href="steam://connect/176.31.38.177:27025/"><i class="fa fa-hand-o-right"></i> Rejoindre</a>
			</div></div>
		</div>
		<div class="item">
			<img alt="MARIO" src="/images/mario{if="$isMobile"}_small{/if}.jpg">
			<div class="flex-caption"><div>
				<p class="title1">Serveur Mario</p> <time>TF2: Mario-Kart <span class="infoServ" data-query="176.31.38.177/27015"></span></time>
				<p class="title2">Le serveur TF2 MarioKart est un serveur DeathMatch, où tu incarne tes classes préférées. L'objectif? Fragger!</p>
				<a class="various btn btn-primary" href="steam://connect/176.31.38.177:27015/"><i class="fa fa-hand-o-right"></i> Rejoindre</a>
			</div></div>
		</div>
<!--
		<div class="item">
			<img alt="FFA" src="/images/ffa{if="$isMobile"}_small{/if}.jpg">
			<div class="flex-caption"><div>
				<p class="title1">Serveur FFA</p>	<time>CSGO: FFA <span class="infoServ" data-query="176.31.38.176/27025"></span></time>
				<p class="title2">Le serveur CSGO: FFA est un serveur sur les maps officielles du jeu. Seul votre skill compte pour remporter la victoire. Ce serveur possède aussi le tick 128, VAC et HLstatX. Si vous voulez faire une war, contacter l'un de nos admins.</p>
				<a class="various btn btn-primary" href="steam://connect/176.31.38.176:27025/"><i class="fa fa-hand-o-right"></i> Rejoindre</a>
			</div></div>
		</div>
-->
	</div>
	<a class="left carousel-control" href="#slider" role="button" data-slide="prev"></a><a class="right carousel-control" href="#slider" role="button" data-slide="next"></a>
</div>
<div class="news">
	<div class="container">
		<article class="col-sm-12"><h2>News</h2>
			<div class="row">{loop="news_list"}<article class="col-sm-3"><div class="list1"><div><time datetime="{$value.date}">{$value.titre}</time><p>{$value.content}<a href="/forum/viewtopic.php?t={$value.topic}" class="btn btn-link">Lire plus</a></p></div></div></article>{/loop}</div>
		</article>
	</div>
</div>
<script type="text/javascript">	$(".infoServ").each( function() { var elem = this; $.getJSON("https://www.ts-x.eu/api/live/stats/" + $(elem).attr("data-query"), function( data ) { $(elem).html("(<b>"+data+"</b>)"); }); });</script>
