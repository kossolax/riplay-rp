				<div class="col-xs-12 col-sm-9">
					<br /><br />
					<center><img id="img_title" class="radius" src="/images/wiki/bug/bug_top.png"></center>
					<br />
					<div class="row">
						<div id="GroupA" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span>
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2>Crash du jeu pendant le téléchargement</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>Il est possible qu'au moment de lancer le téléchargement de la carte, votre jeu crash et se ferme.</p>
									<br />
									<img alt="conection_serveur" class="img_wiki" src="/images/wiki/bug/bug1.jpg"><br />
									<br />
									<p>Pour résoudre ce désagrément, deux solutions s'offrent à vous :</p>
										<ul>
											<li id="GroupASub1">
												<p><u><b>La première solution</b></u> consiste simplement en une simple vérification de votre version Windows enregistrée sur Steam,<br />
												direction donc : </p>
												<br />
												<u><b>C:\Program Files\Steam\SteamApps\common\Counter-Strike Global Offensive</b></u>
												<br />
												<p>Trouvez votre fichier csgo.exe, faites clic droit => propriété</p>
												<br />
												<img alt="img_nav" class="img_wiki" src="/images/wiki/bug/bug2.png"><br />
												<br />
												<p>Vous aurez alors une nouvelle fenêtre, sélectionnez l'onglet "Compatibilité" et vérifiez que la version est réglée sur votre version de Windows ou sur la version Windows 8 si vous êtes sur Windows 10.</p>
												<br />
												<img alt="img_vers_win" class="img_wiki" src="/images/wiki/bug/bug3.png"><br />
												<br />
											</li>
											<br />
											<li id="GroupASub2">
												<p><u><b>La deuxième solution</b></u>, beaucoup plus radicale, <br />
												consiste à baisser votre qualité graphique au minimum, vous mettre en plein écran fenêtré et enfin vous baissez votre rendu multicoeur au minimum comme sur la photo ci-jointe.</p>
												<br />
												<img class="img_wiki" src="/images/wiki/bug/bug4.png">
												<br />
											</li>
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
										<div class="panel-heading panel-heading-wiki"><h2>Problème de retour Windows</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>
										<ul>
											<li>Qu'est-ce que ce bug ?</li>
											<p>De base, lorsqu'on fait un retour Windows (Alt+Tab), l'OS n'alloue plus autant de ressources qu'il le faisait quand vous étiez en jeu,<br />
											ce qui provoque des ralentissements quand vous faites le retour Windows ainsi que quand vous retournez sur le jeu.<br />
											Vous avez un écran noir qui dure 30 secondes avant d'avoir accès au jeu, ensuite vous avez encore 20 secondes à attendre, car le jeu subit des ralentissements, soit au total 50 secondes pour revenir en jeu.</p>
											<p>Suite à une mise à jour du jeu, ce bug a été partiellement corrigé, mais vous devez attendre tout de même 50 secondes avant de pouvoir jouer,<br />
											quand vous faites le retour Windows par contre, vous ne laguez plus. </p><br />
											<li>Comment résoudre ce bug
												<ul>
													<li>Tout d'abord, rendez-vous dans la bibliothèque Steam,</li>
													<li>Cliquez droit sur Counter-Strike : Source ou Counter-Strike: Globale Offensive puis cliquez gauche sur "Propriétés",</li>
													<li>Cliquez sur "Définir les options de lancement...",</li>
													<li>Une fenêtre s'ouvre et écrivez-y "-autoconfig" ou "-safe" (à utiliser séparément). Il ne reste plus qu'à cliquer sur ok,</li>
													<li>Si vous avez déjà le "-console" faites un espace et écrivez-la à la suite.</li>
												</ul>
											</li>
										</ul>
										<br />
										<div class="row">
											<div class="col-md-offset-1 col-md-3 col-xs-6">
												<a class="thumbnail" data-toggle="modal" data-target="#myModal1">
													<img class="img_wiki" src="/images/wiki/bug/bug5.png">
												</a>
											</div>
											<div id="myModal1" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
													<div class="modal-dialog modal-lg">
														<div class="modal-content">
															<div class="modal-body">
																<div class="thumbnail img-thumbnail color-border" style="overflow:hidden;margin:0 auto;"><img src="/images/wiki/bug/bug5.png" /></div><br />
															</div>
															<div class="modal-footer">
																<div class="btn btn-default" data-dismiss="modal">Fermer</div>
															</div>
														</div>
													</div>
											</div>
											<div class="col-md-3 col-xs-6">
												<a class="thumbnail" data-toggle="modal" data-target="#myModal2">
													<img class="img_wiki" src="/images/wiki/bug/bug6.png">
												</a>
											</div>
											<div id="myModal2" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
													<div class="modal-dialog modal-lg">
														<div class="modal-content">
															<div class="modal-body">
																<div class="thumbnail img-thumbnail color-border" style="overflow:hidden;margin:0 auto;"><img src="/images/wiki/bug/bug6.png" /></div><br />
															</div>
															<div class="modal-footer">
																<div class="btn btn-default" data-dismiss="modal">Fermer</div>
															</div>
														</div>
													</div>
											</div>
											<div class="col-md-3 col-xs-6">
												<a class="thumbnail" data-toggle="modal" data-target="#myModal3">
													<img class="img_wiki" src="/images/wiki/bug/bug7.png">
												</a>
											</div>
											<div id="myModal3" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
													<div class="modal-dialog modal-lg">
														<div class="modal-content">
															<div class="modal-body">
																<div class="thumbnail img-thumbnail color-border" style="overflow:hidden;margin:0 auto;"><img src="/images/wiki/bug/bug7.png" /></div><br />
															</div>
															<div class="modal-footer">
																<div class="btn btn-default" data-dismiss="modal">Fermer</div>
															</div>
														</div>
													</div>
											</div>
										</div>
									</p>
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
										<div class="panel-heading panel-heading-wiki"><h2>Retour à l'écran d'accueil</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>Si au moment où vous lancez la map vous revenez à l'écran d’accueil, le problème vient du téléchargement de la map. Il vous suffit d'aller dans vos dossiers et de suivre les instructions suivantes.</p><br />
									<p>Allez dans : <u><b>C:\Program Files\Steam\SteamApps\common\Counter-Strike Global Offensive\csgo\Maps</b></u></p><br />
									<p>Arrivé à ce stade vous supprimez la map Princeton ou, si la map ne s'affiche pas vous devrez supprimer toutes les maps.<br />
									Quand la map est supprimée, il vous suffit de relancer Global offensive et lancer la connexion au serveur.<br /></p>
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
										<div class="panel-heading panel-heading-wiki"><h2>Impossible de rejoindre le serveur</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>Il arrive par moments que vous ne puissiez pas rejoindre le serveur, et alors ces deux fenêtres apparaissent l'une à la suite de l'autre :</p>
									<br />
									<img alt="img_vers_win" class="img_wiki" src="/images/wiki/bug/bug8.png"><br />
									<br />
									<p>Malheureusement, nous ne pouvons rien y faire, car le problème vient de Steam lui-même, soit parce que leurs serveurs on plantés, <br />
									soit parce qu'ils font des mises à jour et nous sommes donc en décalage au niveau de la version.
									(ex : 13h30 le serveur est en 1.2.56, steam fait une mise à jour et passe en 1.2.57. Il nous faudra alors relancer le serveur. Mais ce cas de figure est plutôt rare). </p>
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
										<div class="panel-heading panel-heading-wiki"><h2>Serveur introuvable</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<br />
									<img alt="img_vers_win" class="img_wiki" src="/images/wiki/bug/bug9.png"><br />
									<br />
									<p>Nous ne sommes plus sur Css, nous sommes passés sur cs:go et ce passage à inclus un changement d'ip.<br />
									La nouvelle ip est : 178.32.42.113:27015 </p>
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
										<div class="panel-heading panel-heading-wiki"><h2>Crash pendant la PvP</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>Les Crashs des joueurs durant les PvP sont fréquents il est possible de "réduire" ceci en suivant ces étapes:</p>
									<ol>
										<li>Désactiver l'affichage de la KILLCAM après votre mort</li>
										<p>(Allez dans Aide & Options / Paramètre de jeux / Rediffusion post-mortem automatiques (non)</p>
										<li>Baissez vos paramètres graphiques lors des PvP</li>
									</ol>
								</div>
							</div>
						</div>
					</div>

				</div>
				<!--Nav Bar
				<nav class="col-md-2 bs-docs-sidebar">
					<ul id="sidebar" class="nav nav-stacked fixed">
						<li>
							<a href="#GroupA">Crash du jeu pendant le téléchargement</a>
							<ul class="nav nav-stacked">
								<li><a href="#GroupASub1">Solution 1</a></li>
								<li><a href="#GroupASub2">Solution 2</a></li>
							</ul>
						</li>
						<li>
							<a href="#GroupB">Problème de retour Windows</a>
						</li>
						<li>
							<a href="#GroupC">Retour à l'écran d'accueil</a>
						</li>
						<li>
							<a href="#GroupD">Impossible de rejoindre le serveur</a>
						</li>
						<li>
							<a href="#GroupE">Serveur introuvable</a>
						</li>
						<li>
							<a href="#GroupF">Crash pendant la PvP</a>
						</li>
					</ul>
				</nav>-->