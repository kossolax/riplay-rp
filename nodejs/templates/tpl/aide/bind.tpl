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
					<center><img alt="img_title" id="img_title" src="https://www.ts-x.eu/images/wiki/save/bind.png"></center><br />
					<br />
					<div class="row">
						<div class="col-md-12" role="main">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span>
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2 id="GroupA" >Qu'est-ce qu'un Bind ?</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>Un bind consiste à rattacher une commande à une touche, cela permet notamment d'ouvrir les menus les plus utiles du RP instantanément et vous faire gagner énormément de temps.
									La procédure depuis CS:GO est devenu assez simple et peut maintenant s'effectuer directement en jeu.</p>
								</div>
							</div>
						</div>
						<div class="col-md-12" role="main">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span>
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2 id="GroupB" >Afficher la console</h2></div>
									</div>
								</div>
								<div class="panel-body">
								<p>Dans un premier temps, notre mission sera d'activer la console dans laquelle on va écrire nos binds. Elle ressemble à ça, la petite barre en bas va nous servir à écrire nos binds.</p><br />
								<img class="img_wiki" src="/images/wiki/bind/1200px-Console.png" /><br /><br />
									<p><strong>Si vous savez déjà comment l'afficher, vous pouvez passer cette étape.</strong><br />
									Pour ouvrir la console, il faudra d'abord l'activer.<br />
									Pour ce faire, allez dans vos options et choisissez : Paramètres de jeu > activez la console développeur (3ème ligne)</p><br />
									<img class="img_wiki" src="/images/wiki/bind/1200px-Activer_console.png" /><br /><br />
									<p>Nous allons ensuite définir une touche pour afficher votre console, rendez-vous dans : options > clavier / souris.<br />
									Descendez tout en bas et choisissez la touche de votre choix:</p><br />
									<img class="img_wiki" src="/images/wiki/bind/1200px-Assigner_une_touche_console.png" /><br />
								</div>
							</div>
						</div>
						<div class="col-md-12" role="main">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span>
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2 id="GroupC" >Ecrire vos Binds</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p><u>Binds pour tous les joueurs :</u></p>
									<ul>
										<li><i>Ouvrir une porte (et la verrouiller) - bind "votretouche" "say /lock;say /use"</i></li>
										<li><i>Ouvrir la liste de vos items - bind "votretouche" "say /item"</i></li>
										<li><i>Déverrouiller une porte - bind "votretouche" "say /unlock"</i></li>
										<li><i>Sortir un joueur de sa planque - bind "votretouche" "say /out"</i></li>
										<li><i>Porter un objet - bind "votretouche" "+force"</i></li>
										<li><i>Bind une touche pour use un item automatiquement bind "votretouche" "say /item;menuselect 1" changer le numéro afin de choisir l'item que vous souhaiter utiliser</i></li>
										<li><i>Poser l'atout de son métier (healbox / barriere / distributeur / ect...) - bind "votretouche" "say /build"</i></li>
									</ul>
									<p><u>Bind pour les métiers de vente :</u></p>
									<ul>
										<li><i>Ouvrir le menu de vente - bind "votretouche" "say /vendre"</i></li>
									</ul>
									<p><u>Bind pour les métiers de vol (Mafieux / 18th) :</u></p>
									<ul>
										<li><i>Voler - bind "votretouche" "say /vol"</i></li>
									</ul>
									<p>Une fois vos binds effectués, sauvegardez les avec la commande <i>"host_writeconfig"</i></p>
								</div>
							</div>
						</div>
						<div class="col-md-12" role="main">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span>
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2 id="GroupD" >Les touches spéciales</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<center><h2 id="GroupDSub1"><u>Le Pavé Numéri</u>q<u>ue</u></h2></center>
									<br />
									<div class="row">
										<div class="col-xs-offset-3 col-xs-3">
											  <img class="img_wiki center-block"src="/images/wiki/bind/Slash.png" alt="/">
											  <p class="text-center">kp_slash</p>
										</div>
										<div class="col-xs-3">
											  <img class="img_wiki center-block" src="/images/wiki/bind/*.png" alt="*">
											  <p class="text-center">KP_Multiply</p>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/-.png" alt="-">
											<p class="text-center">KP_minus</p>
											</a>
										</div>
									</div>
									<div class="row">
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/7.png" alt="7">
											<p class="text-center">kp_home</p>
											</a>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/8.png" alt="8">
											<p class="text-center">kp_uparrow</p>
											</a>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/9.png" alt="9">
											<p class="text-center">kp_pgup</p>
											</a>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/+.png" alt="+">
											<p class="text-center">kp_plus</p>
											</a>
										</div>
									</div>
									<div class="row">
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/4.png" alt="4">
											<p class="text-center">kp_leftarrow</p>
											</a>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/5.png" alt="5">
											<p class="text-center">kp_5</p>
											</a>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/6.png" alt="6">
											<p class="text-center">kp_rightarrow</p>
											</a>
										</div>
									</div>
									<div class="row">
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/101.png" alt="1">
											<p class="text-center">kp_end</p>
											</a>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/2.png" alt="2">
											<p class="text-center">kp_downarrow</p>
											</a>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/3.png" alt="3">
											<p class="text-center">kp_pgdn</p>
											</a>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/Entr.png" alt="enter">
											<p class="text-center">kp_enter</p>
											</a>
										</div>
									</div>
									<div class="row">
										<div class="col-xs-offset-3 col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/0i.png" alt="0">
											<p class="text-center">kp_ins</p>
											</a>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/point.png" alt=".">
											<p class="text-center">kp_del</p>
											</a>
										</div>
									</div>
									<br />
									<hr class="featurette-divider">
									<br />
									<center><h2 id="GroupDSub2"><u>Le Control Pad</u></h2></center>
									<br />
									<div class="row">
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/Pgup.png" alt="PGUP">
											<p class="text-center">PGUP</p>
											</a>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/Suppr.png" alt="DEL">
											<p class="text-center">DEL</p>
											</a>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/Fin.png" alt="END">
											<p class="text-center">END</p>
											</a>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/Inser.png" alt="INS">
											<p class="text-center">INS</p>
											</a>
										</div>
									</div>
									<div class="row">
										<div class="col-xs-offset-3 col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/AD.png" alt="SCROLL">
											<p class="text-center">SCROLLLOCK</p>
											</a>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/).png" alt="]">
											<p class="text-center">]</p>
											</a>
										</div>
										<div class="col-xs-3">
											<img class="img_wiki center-block" src="/images/wiki/bind/+=.png" alt="=">
											<p class="text-center">=</p>
											</a>
										</div>
									</div>
									<br />
									<hr class="featurette-divider">
									<br />
									<div class="row">
									<center><h2 id="GroupDSub3"><u>Les flèches directionelles</u></h2></center>
									<br />
										<div class="col-xs-offset-5 col-xs-2">
											<img class="img_wiki center-block" src="/images/wiki/bind/uparrow.png" alt="Flèche haut">
											<p class="text-center">uparrow</p>
											</a>
										</div>
									</div>
									<div class="row">
										<div class="col-xs-offset-3 col-xs-2">
											<img class="img_wiki center-block" src="/images/wiki/bind/leftarrow.png" alt="Flèche gauche">
											<p class="text-center">leftarrow</p>
											</a>
										</div>
										<div class="col-xs-2">
											<img class="img_wiki center-block" src="/images/wiki/bind/downarrow.png" alt="Flèche bas">
											<p class="text-center">downarrow</p>
											</a>
										</div>
										<div class="col-xs-2">
											<img class="img_wiki center-block" src="/images/wiki/bind/rightarrow.png" alt="Flèche droite">
											<p class="text-center">rightarrow</p>
											</a>
										</div>
									</div>
									<br />
									<hr class="featurette-divider">
									<br />
									<center><h2 id="GroupDSub4"><u>La Souris</u></h2></center>
									<br />
									<table class="wiki-table-prune">
										<tbody>
											<tr>
												<th id="table-top-left">Position</th>
												<th id="table-top-right">Commande</th>
											  </tr>
											<tr>
												<td><p class="txt">Molette haut</p></td>
												<td><p class="txt">MWHEELUP</p></td>
											</tr>
											<tr>
												<td><p class="txt">Molette bas</p></td>
												<td><p class="txt">MWHEELDOWN</p></td>
											</tr>
											<tr>
												<td><p class="txt">Click molette</p></td>
												<td><p class="txt">MOUSE3</p></td>
											</tr>
											<tr>
												<td><p class="txt">Bouton 1 côté</p></td>
												<td><p class="txt">MOUSE1</p></td>
											</tr>
											<tr>
												<td><p class="txt">Bouton 2 côté</p></td>
												<td><p class="txt">MOUSE2</p></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
				<!--Nav Bar
				<nav class="col-md-2 bs-docs-sidebar">
					<ul class="nav nav-stacked fixed">
						<li><a href="#GroupA" id="page_menu_wiki" ><i class="fa fa-asterisk prune" aria-hidden="true"></i> Qu'est-ce qu'un Bind </a></li>
						<li><a href="#GroupB" id="page_menu_wiki" ><i class="fa fa-asterisk ocean" aria-hidden="true"></i> Afficher la console</a></li>
						<li><a href="#GroupC" id="page_menu_wiki" ><i class="fa fa-asterisk gold" aria-hidden="true"></i> Ecrire vos Binds</a></li>
						<li><a href="#GroupD" id="page_menu_wiki" ><i class="fa fa-asterisk pomme" aria-hidden="true"></i> Les touches spéciales</a>
							<ul class="nav nav-stacked">
								<li><a href="#GroupDSub1">Le Pavé Numérique</a></li>
								<li><a href="#GroupDSub2">Le Control Pad</a></li>
								<li><a href="#GroupDSub3">Les flèches directionelles</a></li>
								<li><a href="#GroupDSub4">La Souris</a></li>
							</ul>
						</li>
					</ul>
				</nav>-->