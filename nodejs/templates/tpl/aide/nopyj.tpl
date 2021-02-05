		{if="$nopyj==1"}
		<div class="alert alert-success" role="alert">Vous avez le rang No-Pyj, félicitation ! N'hésitez pas à aider les autres joueurs ;)</div>	
		{else} 
			{if="$age>=16"} 
			<div class="alert alert-warning" role="alert">Vous etes élligible au No-Pyj ! Contactez nous sur Teamspeack pour le passer =)</div>
			{else}
			<div class="alert alert-info" role="alert">Vous pourrez décrochez votre No-Pyj à vos 16 ans, courage ! </div>
			{/if}
		{/if}
			<div class="row">
				<div class="col-sm-3 hidden-phone">
					<div class="container">
						<div class="col-sm-3 hidden-phone">
							<div class="panel-group" id="accordion">
								<!--<div class="panel panel-wiki">
									<div class="panel-heading">
										<h4 class="panel-title title-nav">
											<a data-toggle="collapse" data-parent="#accordion" href="#MenuOne"><i class="fa fa-chevron-right" aria-hidden="true"></i>
											Index</a>
										</h4>
									</div>
									<div id="MenuOne" class="panel-collapse collapse">
										<ul class="list-group">
											<li class="list-group-item"><a href="#GroupA">Présentation</a></li>
											<li class="list-group-item"><a href="#GroupB">Les Référés</a></li>
											<li class="list-group-item"><a href="#GroupC">Passer VIP</a></li>
											<li class="list-group-item"><a href="#GroupD">Devenir Membre CS:GO</a></li>
										</ul>
									</div>
								</div>-->
								<div ng-include="'/templates/tpl/aide/menu.tpl'"></div>			
							</div>
						</div>
					</div>
				</div>
				<div class="col-xs-12 col-sm-9">
				<br /><br />
				<center><img id="img_title" class="radius" src="/images/wiki/nopyj/nopyj_top.png"></center>
				<br />
					<div class="row">
						<div id="GroupA" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span> 
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2>Qu'est-ce que le rang "No-Pyj" ?</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>Le Rang "no-pyj" est un grade qui est attribué aux plus matures, droits et sages d'entre vous, il vous permet d'acquérir différents bonus sur nos serveurs et notre forum.</p>
									<br />
									<ul>
										<li><p>Sur le forum, vous aurez une notification "Rang: no-pyj" en dessous de l'avatar des personnes ayant ce rang, ainsi que l'accès à la partie "forum des No-pyj"</p></li>
										<br />
										<li><p>Sur le Serveur, il vous permettra d'utiliser la commande "/annonce" ou "/me" afin de rendre votre publication plus lisible.<br />
										Mais attention, l'utilisation de cette commande est soumise à une règlementation que vous retrouverez dans le <a target="_blank" href="/forum/viewtopic.php?f=10&t=26749"> règlement général</a></p></li>
									</ul>
								</div>
							</div>
						</div>
						<div id="GroupB" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span> 
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2>Les conditions d'éligibilités</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>Le rang "No-Pyj" est soumis à certaines conditions d'éligibilités, il vous faudra :</p>
									<br />
									<ul>
									<li><p>Avoir 16 ans minimum. ( Le bandeau sur cette page est basé sur l'âge de votre profil forum, pensez donc à donner votre vrai âge ! )</li>
									<li><p>Avoir un compte sur le forum.<p></li>
									<li><p>Avoir lié votre compte forum à votre Steam ID.<p></li>
									<li><p>Avoir posté sur le forum au minimum 1 message.<p></li>
									<li><p>Connaître toutes les informations que vous trouverez dans ce tutoriel.<p></li>
									<li><p>Connaître les sections suivantes du <a target="_blank" href="/forum/viewtopic.php?f=10&t=26749"> règlement général</a> :
										<ul>
											<li><p>Le règlement général du serveur<p></li>
											<li><p>Les points particuliers<p></li>
										</ul><p></li>
									<li><p>Vous munir d'une photo récente de vous<p></li>
								</ul>
								<br />
								<p>Une fois ces conditions remplies, vous devrez vous rendre sur notre <a href="ts3server://ts.ts-x.eu/?port=9987">TeamSpeak</a> et demander à un admin de vous le faire passer.</p>
								<p>Une fois connecté, le meilleur moyen de contacter un admin est de vous rendre dans le channel "Besoin d'un admin? - Public & calme".</p>
								<br />
								<p><span class="blood"> /!\ Attention /!\ </span>  Si c'est votre première connexion sur notre teamspeak, vous vous retrouverez dans le "hall" avec un cadenas,<br />
								il vous empêchera de faire une quelconque action, vous devrez suivre le lien que vous a envoyé le bot et vous connecter au forum pour vous débloquer</p>
								</div>
							</div>
						</div>
						<div id="GroupC" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span> 
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2>Le Test No-Pyj</h2></div>
									</div>
								</div>
								<div class="panel-body">
								<p>Une fois les conditions remplies et l'admin contacté, ce dernier vous posera quelques questions de routine et
								si tout va bien, vous donnera un lien.<br />
								<span class="blood">Attention !</span> en cliquant sur ce lien, vous démarrerez directement le test !</p>
								<p>Le test se compose d'une série de 10 questions générées aléatoirement par un bot, vous aurez 1 question pour
								4 réponses possibles.<br />
								Un résultat de 8/10 minimum est attendu pour pouvoir décrocher votre rang, pensez donc à bien réviser !</p>
								</div>
							</div>
						</div>
						<div id="GroupD" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span> 
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2>À quoi sert le rang No-Pyj ?</h2></div>
									</div>
								</div>
								<div class="panel-body">
								<p>Le rang "No-Pyj" à de multiples avantages, il vous permettra entre autres de :</p>
								<br />
									<ul>
										<li><p>Devenir chef d'un job.<p></li>
										<li><p>Avoir accès à une partie privée du forum (Forum des no-pyj)<p></li>
										<li><p>Avoir le "+force" dans la rue. (Tenir une personne avec le grade adéquat).<p></li>
										<li><p>Avoir le "/me" (annonces), qui vous permettra en outre de pouvoir faire des annonces , message blanc qui est mieux visible et qui tape à l'oeil.<p></li>
										<li><p>Possibilité d'écrire moins que toutes les 10 secondes dans le chat.<p></li>
										<li><p>Pouvoir juger les plaintes au tribunal forum.<p></li>
									</ul>
								</div>
							</div>
						</div>
						<div id="GroupE" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span> 
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2 id="t4" >Gérer une plainte Tribunal Forum</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<h3><u>1 ~ Soumettre une plainte</u></h3><br />
										<ul>
											<li><p>Grâce au tribunal forum, vous pourrez soumettre sous forme de "plainte" tous les abus que vous ayez pu remarquer en jeu qui ne peut ou qui n'a pu être traité en jeu par un juge.<p></li>
											<li><p>Pour envoyer votre plainte, c'est très simple, 
												<ul>
													<li><p>Par le Forum, allez sur l'onglet Roleplay puis sélectionnez "Le tribunal" et cliquez en haut à droite sur "Rapporter un mauvais comportement".<p></li>
													<center><img class="img_wiki" src="images/wiki/nopyj/tribu_forum.png"/></center>
													<li><p>In Game, vous trouverez partout dans la ville des téléphones, il vous suffira de faire "e" en les visant ou bien de taper / report dans le tchat.<p></li>
												</ul>
										<br />
										<p><u>Voici un exemple de plainte :</u></p>
										<br />
										<img class="img_wiki" src="/images/wiki/nopyj/report_tribu.png"/>
										<br /><br />
										<p><strong class="blood">Le SteamID à indiquer est celui de l'accusé !</strong></p>
										<br /><br />
										<h3><u>2 ~ Traiter une plainte</u></h3><br />
											<ul>
										<li><p>Quand le rang no-pyj est acquis, le tribunal forum permet de juger les personnes ayant reçu une plainte, <br />
										pour y accéder il vous faudra vous rendre au même endroit que pour soumettre une plainte, à une exception près, vous devrez cliquer sur le bouton "S'occuper du tribunal"</p></li><br />
										<p>Cela vous redirigera sur la page "le tribunal : le règlement", et en bas de la page, il vous suffira de cliquer sur "j'ai lu le règlement, et je souhaite traiter un cas".<p>
										<br />
										<li><p>L'image ci-dessous, correspond aux informations générales de l'accusé (Pseudo, job, argent, etc...) <br /><br />
										<img class="img_wiki" src="/images/wiki/nopyj/recap_tribu.png"/>
										<p></li>
										<br />
										<li><p>L'image ci-dessous correspond à l'endroit où se trouve la raison de la plainte et les informations relatives à cette plainte.<br />
										Ainsi que les choix qui vous sont offerts pour donner un verdict, réfléchissez bien avant de le rendre !<br /><br />
										<img class="img_wiki" src="/images/wiki/nopyj/raison_tribunal.png"/>
										<p></li>
										<br />
										<li><p>L'image ci-dessous correspond aux logs, vous y trouverez toutes les informations nécessaires afin de traiter la plainte (messages, meurtres, décès, prison, etc...)<br /><br />
										<img class="img_wiki" src="/images/wiki/nopyj/log_tribu.png"/>
										<p></li>
										<br />
									</ul>
								</div>
							</div>
						</div>
						<div id="GroupF" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span> 
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2>Perdre le No-Pyj</h2></div>
									</div>
								</div>
								<div class="panel-body">
								<p>Dans certaines circonstances exceptionnelles il est possible que l'on vous retire votre rang "No-Pyj", mais cela sera seulement en cas de grosse bêtise comme :</p>
									<ul>
										<li><p>Si vous abusez d'une quelconque commande hors de son contexte prévu<p></li>
										<li><p>Des multiples bans pour des raisons de comportement nuisible <p></li>
										<li><p>Si vous ne respectez pas votre engagement de chef de job<p></li>
									</ul>
								<p>Bien évidemment cette liste est non exhaustive et ne représente que quelques-uns des cas les plus fréquents, une fois votre
								rang "No-Pyj" perdu, vous n'aurez plus accès à ce rang et ne pourrez repasser l'examen qu'en cas de réels changements de votre part.</p><br />
								<p>Ainsi si vous possédez le rang "No-Pyj", vous devrez respecter le <a target="_blank" href="/forum/viewtopic.php?f=10&t=26749"> règlement général</a>
								et ne pas nuire volontairement à la communauté ou au serveur.
								En passant ce rang, vous attestez avoir pris conscience du règlement général et avoir accepté celui-ci.</p>
								</div>
							</div>
						</div>
						<div id="GroupG" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span> 
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2>Le rang "No-Pyj émancipé"</h2></div>
									</div>
								</div>
								<div class="panel-body">
								<p>Dans certaines circonstances exceptionnelles il est possible que l'on vous accorde le rang "No-Pyj émancipé", mais ce grade n'est pas accordé au premier venu...<br /><br />
								Les "No-Pyj émancipé" sont des joueurs qui n'ont pas l'âge requis pour avoir le rang "No-Pyj" mais qui connaissent très bien le règlement et ont fait preuve d'un comportement exemplaire,
								ce rang vous accorde les mêmes avantages que le rang "No-Pyj" côté Forum (Forum "no-pyj" et place de chef de job) mais pas côté serveur (+force ou /me).</p>
								<br />
								<p><center><span style="color:red;font-size:20px;"><u>Attention :</u></span> </center>
								<br />La Première condition pour passer le "No-Pyj émancipé" est de ne pas demandé quel en sont les conditions, ensuite il vous faudra avoir aucun ban à votre actif
								et avoir un certain montant de temps de jeux sur le Rôle-Play</p>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
				<!--Nav Bar
				<nav class="col-md-2 bs-docs-sidebar">
					<ul id="sidebar" class="nav nav-stacked fixed">
						<li>
							<a href="#GroupA">Qu'est-ce que le rang "No-Pyj" ?</a>
						</li>
						<li>
							<a href="#GroupB">Les conditions d'éligibilités</a>
						</li>
						<li>
							<a href="#GroupC">Le Test No-Pyj</a>
						</li>
						<li>
							<a href="#GroupD">A quoi sert le rang "No-Pyj" ?</a>
						</li>
						<li>
							<a href="#GroupE">Gérer une plainte Tribunal Forum</a>
						</li>
						<li>
							<a href="#GroupF">Perdre son "No-Pyj"</a>
						</li>
						<li>
							<a href="#GroupG">Le rang "No-Pyj" émancipé</a>
						</li>
					</ul>
				</nav>-->
