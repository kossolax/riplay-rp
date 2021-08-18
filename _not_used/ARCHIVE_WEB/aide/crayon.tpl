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
					<center><img id="img_title" class="radius" src="/images/wiki/crayon/crayon.png"></center>
					<br />
					<div class="row">
						<div id="GroupA" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span>
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2>À quoi ça sert ?</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>Le crayon de couleur est un item proposé par les Coachs au prix de 900 $Rp.<br />
									Une fois l'item activé, il est valable jusqu'à votre déconnexion et vous permettra de mettre de la couleur dans votre vie ainsi que de simplifier certaines commandes !</p>
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
										<div class="panel-heading panel-heading-wiki"><h2>Les couleurs</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<table class="wiki-table-prune">
										<tr>
											<th id="table-top-left">Balise</th>
											<th id="table-top-right">Couleur</th>
										</tr>
										<tr class="active-light">
											<td>{darkred}</td>
											<td><span style="color:#bb1d1a;">Bordeaux</span></td>
										</tr>
										<tr>
											<td>{green} </td>
											<td><span style="color:#5de760;">Vert</span></td>
										</tr>
										<tr>
											<td>{lightgreen}</td>
											<td><span style="color:#a8bc87;">Vert clair</span></td>
										</tr>
										<tr>
											<td>{lime}</td>
											<td><span style="color:#aae765;">Citron vert</span></td>
										</tr>
										<tr>
											<td>{red}</td>
											<td><span style="color:#d63b37;">Rouge</span></td>
										</tr>
										<tr>
											<td>{grey}</td>
											<td><span style="color:#cecbc2;">Gris</span></td>
										</tr>
										<tr class="active-light">
											<td>{olive}</td>
											<td><span style="color:#ece87c;">Jaune foncé</span></td>
										</tr>
										<tr>
											<td>{lightblue}</td>
											<td><span style="color:#668db8;">Bleau clair</span></td>
										</tr>
										<tr>
											<td>{blue}</td>
											<td><span style="color:#525db9;">Bleue</span></td>
										</tr>
										<tr>
											<td>{purple}</td>
											<td><span style="color:#b443b7;">Violet</span></td>
										</tr>
										<tr>
											<td>{darkorange}</td>
											<td><span style="color:#bf5b5d;">Orange foncé</span></td>
										</tr>
										<tr>
											<td>{orange}</td>
											<td><span style="color:#d9ae2b;">Orange</span></td>
										</tr>
									</table>
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
										<div class="panel-heading panel-heading-wiki"><h2>Les balises d'effets</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<table class="wiki-table-pomme">
										<tr>
											<th id="table-top-left">Balise</th>
											<th id="table-top-right">Zones d'effet</th>
										</tr>
										<tr>
											<td>{cagnotte}</td>
											<td>Affiche le montant total (en $RP) présent dans la cagnotte</td>
										</tr>
										<tr>
											<td>{hp}</td>
											<td>Les points de vie</td>
										</tr>
										<tr>
											<td>{ap}</td>
											<td>Le Kevlar</td>
										</tr>
										<tr>
											<td>{heure}</td>
											<td>L'heure</td>
										</tr>
										<tr>
											<td>{minutes}</td>
											<td>Les minutes</td>
										</tr>
										<tr>
											<td>{job}</td>
											<td>Le rang du métier dans lequel vous êtes</td>
										</tr>
										<tr>
											<td>{gang}</td>
											<td>Le rang du gang dans lequel vous êtes</td>
										</tr>
										<tr>
											<td>{zone}</td>
											<td>La zone dans laquelle vous êtes</td>										</tr>
										<tr>
											<td>{date}</td>
											<td>La date sur le Rôle-Play</td>
										</tr>
										<tr>
											<td>{me} ou {client}</td>
											<td>Votre pseudo</td>
										</tr>
										<tr>
											<td>{target}</td>
											<td>Ce que vous visez</td>
										</tr>
										<tr>
											<td>{door}</td>
											<td>La porte visée</td>
										</tr>
									</table>
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
										<div class="panel-heading panel-heading-wiki"><h2>Comment les utiliser ?</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<div class="row">
										<p>Directement en jeu : </p><br /><br />
										<div class="col-sm-6">
											<img class="img_wiki" src="/images/wiki/crayon/crayon.jpg" />
										</div>
										<div class="col-sm-6">
											<img class="img_wiki" src="/images/wiki/crayon/crayon1.jpg" />
										</div>
									</div>
									<div class="row">
										<br /><br />
										<p>Dans votre pseudo steam :</p><br /><br />
										<div class="col-sm-6">
											<img class="img_wiki" src="/images/wiki/crayon/crayon2.png" />
										</div>
										<div class="col-sm-6">
											<img class="img_wiki" src="/images/wiki/crayon/crayon3.jpg" />
										</div>
									</div>
									<div class="row">
										<br /><br />
										<p>Ou via un bind :</p><br /><br />
										<div class="col-sm-6">
											<img class="img_wiki" src="/images/wiki/crayon/crayon4.jpg" />
										</div>
										<div class="col-sm-6">
											<img class="img_wiki" src="/images/wiki/crayon/crayon5.jpg" />
										</div>
									</div>
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
							<a href="#GroupA">À quoi ça sert ?</a>
						</li>
						<li>
							<a href="#GroupB">Les couleurs</a>
						</li>
						<li>
							<a href="#GroupC">Les balises d'effets</a>
						</li>
						<li>
							<a href="#GroupD">Comment les utiliser ?</a>
						</li>
					</ul>
				</nav>-->