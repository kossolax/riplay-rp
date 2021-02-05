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
					<center><img id="img_title" class="radius" src="/images/wiki/record/record_top.png"></center>
					<br />
					<div class="row">
						<div id="GroupA" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span>
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2>Fraps</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<div class="row">
										<p>Après avoir téléchargé et installé <a target="_blank" href="http://www.fraps.com/">FRAPS</a>, vous le lancez et vous arriverez sur cette page :</p>
										<br />
										<img class="img_wiki" src="/images/wiki/record/fraps1.png"/>
										<br /><br />
										<p>Pour configurer le mode vidéo,cliquez sur "Movies" :
											<ul>
												<li>Dans la case "Folder to save movies in" vous pouvez choisir l'emplacement de stockage de vos vidéos prises en jeu. (Vous retrouverez donc vos records directement à l'emplacement que vous avez choisi).</li>
												<li>Dans la case "Video Capture Hotkey" vous pouvez choisir une touche avec laquelle vous pourrez commencer la record. (Une record dure au maximum 30 secondes).</li>
											</ul>
										</p>
										<br />
										<img class="img_wiki" src="/images/wiki/record/fraps2.png"/>
										<br />
									</div>
									<br />
									<div id="GroupASub1" class="row">
										<p>
										Comme vous le savez surement les vidéos faites avec FRAPS sont extrêmement lourdes, il va donc falloir la compresser.
										<br />
										Pour compresser la vidéo, nous allons utiliser un logiciel très simple, <a target="_blank" href="https://handbrake.fr/downloads.php">Handbrake</a>.
										<ol>
											<li>Allez sur "Source".</li>
											<li>Choisissez "File" puis sélectionnez la vidéo à importer.</li>
											<li>Choisissez iPhone et iPod touch pour une compression optimale (meilleur ratio qualité / poids).</li>
											<li>Cliquez ensuite sur "Browse" et choisissez le lieu ou enregistrer la vidéo compressée.</li>
											<li>Lancez la compression en appuyant sur start.</li>
										</ol>
										</p>
										<br />
										<img class="img_wiki" src="/images/wiki/record/fraps3.JPG"/>
										<br /><br />
										<img class="img_wiki" src="/images/wiki/record/fraps4.JPG"/>
										<br />
									</div>
								</div>
							</div>
						</div>
						<br />
						<div id="GroupB" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span>
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2>Windows 10</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>Sous Windows 10, il y a un logiciel de record nativement installé pour vos jeux.<br />
									Pour l'activer ou le désactiver, il vous suffit de presser votre touche Windows et la touche G simultanément.<br />
									Ou alors vous pouvez aussi presser les touches Windows + alt + r pour lancer et arrêter la record plus rapidement.</p>
									<br />
									<img class="img_wiki" src="/images/wiki/record/record_w10.png"/>
									<br />
									<p>Ce menu s'ouvrira alors et il vous suffira de cliquer sur le bouton rouge pour lancer la record ou l'arrêter.<br />
									Vous pourrez retrouver votre enregistrement dans
									<span class="wiki-phone">"C:\Users\VOTRE_NOM_DE_SESSION\Videos\Captures"</span>.</p>
								</div>
							</div>
						</div>
						<br />
						<div id="GroupC" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span>
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2>Steam</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>Pour faire une record avec Steam, il vous faudra tout d'abord avoir la console en jeu.<br />
									Vous pouvez trouver <a target="_blan" href="/index.php?page=aide&sub=bind#t2">sur cette page</a> un tutoriel sur comment l'afficher.</p>
									<br />
									<p>Une fois fait, vous pouvez accéder à votre console à n'importe quel moment.<br />
									<br />
									Pour lancer une record il vous suffit d'écrire : Record Nomdelarecord</p>
									<br />
									<img class="img_wiki" src="/images/wiki/record/steam_r1.png"/>
									<br /><br />
									<p>Si vous pensez avoir fini votre record vous retournez sur votre console et vous inscrivez : Stop</p>
									<br />
									<img class="img_wiki" src="/images/wiki/record/steam_r2.png"/>
									<br /><br />
									<p>Pour retrouver votre record, il vous suffit d'aller dans Steam>SteamApps>Common>Counter-Strike Global Offensive>csgo<br />
									( vous descendez votre page une fois dans "csgo" vous trouverez votre nom de record en .dem)</p>
								</div>
							</div>
						</div>
						<br />
						<div id="GroupD" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span>
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2>Envoyer une vidéo sur Youtube</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>Après vous avoir créé une chaine YouTube, si cela n'est pas déjà fait, connectez-vous à votre compte.<br />
									À la gauche de votre écran, cliquez sur l'onglet "Ma Chaine" qui vous permettra d’accéder à votre propre chaine.</p>
									<br />
									<img class="img_wiki" src="/images/wiki/record/ytub1.png"/>
									<br /><br />
									<p>Une fois arrivé dans votre chaine vous arriverez sur cette page :</p>
									<br />
									<img class="img_wiki" src="/images/wiki/record/ytub2.png"/>
									<br /><br />
									<p>Il vous suffit de cliquer sur "Vidéos" pour poursuivre la publication.<br />
									Au milieu de votre écran, il vous apparaîtra ceci :</p>
									<br />
									<img class="img_wiki" src="/images/wiki/record/ytub3.png"/>
									<br /><br />
									<p>
									Cliquez sur "Mettre en ligne une vidéo".<br />
									<br />
									Ensuite, pour choisir votre record à envoyer, cliquez sur "Sélectionner les fichiers à importer" puis aller dans l'emplacement où se trouve votre record avec FRAPS<br />
									(celui que vous avez choisi dans "Folder to save movies in") et choisissez la record que vous voulez nous partager.
									</p>
									<br />
									<img class="img_wiki" src="/images/wiki/record/ytub4.png"/>
									<br /><br />
									<p>
									Enfin, une fois votre record sélectionné, vous choisirez un titre à votre vidéo ainsi qu'une brève description.<br />
									Les "Tags" sont des mots-clés descriptifs que vous pouvez ajouter à votre vidéo afin d'aider à découvrir le contenu de votre vidéo.<br />
									<br />
									À gauche vous trouverez le lien de votre vidéo (Record) que vous pourrez nous faire partager afin que nous puissions la regarder.<br />
									Une fois cela terminé, cliquez sur "Publier", vous retrouverez votre vidéo dans votre Chaine.
									</p>
									<br />
									<img class="img_wiki" src="/images/wiki/record/ytub5.png"/>
									<br />
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
				<!--<nav class="col-md-2 bs-docs-sidebar">
					<ul id="sidebar" class="nav nav-stacked fixed">
						<li>
							<a href="#GroupA">Fraps</a>
								<ul class="nav nav-stacked">
									<li><a href="#GroupASub1">Compresser la vidéo</a></li>
								</ul>
						</li>
						<li>
							<a href="#GroupB">Windows 10</a>
						</li>
						<li>
							<a href="#GroupC">Steam</a>
						</li>
						<li>
							<a href="#GroupD">Envoyer une vidéo sur Youtube</a>
						</li>
					</ul>
				</nav>-->