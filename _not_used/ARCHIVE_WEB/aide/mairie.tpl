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
					<!-- Carrousel -->
					<div id="slider" class="carousel slide" data-ride="carousel">
						<ol class="carousel-indicators"><!-- Bulle de navigation -->
							<li data-target="#slider" data-slide-to="0" class="active"></li>
							<li data-target="#slider" data-slide-to="1" class=""></li>
							<li data-target="#slider" data-slide-to="2" class=""></li>
							<li data-target="#slider" data-slide-to="3" class=""></li>
							<li data-target="#slider" data-slide-to="4" class=""></li>
							<li data-target="#slider" data-slide-to="5" class=""></li>
							<li data-target="#slider" data-slide-to="6" class=""></li>
							<li data-target="#slider" data-slide-to="7" class=""></li>
						</ol>
						<div class="carousel-inner" role="listbox">
							<div class="item active"><!-- Slide 0 -->
								<img id="img_carrousel" alt="mairie" src="/images/wiki/mairie/mairie.jpg" /></a>
							</div>
							<div class="item"><!-- Slide 1 -->
								<img id="img_carrousel" alt="mairie" src="/images/wiki/mairie/mairie1.jpg" /></a>
							</div>
							<div class="item"><!-- Slide 2 -->
								<img id="img_carrousel" alt="mairie" src="/images/wiki/mairie/mairie2.jpg" /></a>
							</div>
							<div class="item"><!-- Slide 3 -->
								<img id="img_carrousel" alt="mairie" src="/images/wiki/mairie/mairie3.jpg" /></a>
							</div>
							<div class="item"><!-- Slide 4 -->
								<img id="img_carrousel" alt="mairie" src="/images/wiki/mairie/mairie4.jpg" /></a>
							</div>
							<div class="item"><!-- Slide 5 -->
								<img id="img_carrousel" alt="mairie" src="/images/wiki/mairie/mairie5.jpg" /></a>
							</div>
							<div class="item"><!-- Slide 6 -->
								<img id="img_carrousel" alt="mairie" src="/images/wiki/mairie/mairie6.jpg" /></a>
							</div>
							<div class="item"><!-- Slide 7 -->
								<img id="img_carrousel" alt="mairie" src="/images/wiki/mairie/mairie7.jpg" /></a>
							</div>
						</div>
						<!-- Controle gauche -->
						<a class="left carousel-control" href="#slider" role="button" data-slide="prev">
						<span class="sr-only">Previous</span></a>
						<!-- Controle droite -->
						<a class="right carousel-control" href="#slider" role="button" data-slide="next">
						<span class="sr-only">Next</span></a>
					</div>
				<br /><br />
				<div class="row">
						<div id="GroupA" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span>
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki"><h2>La Mairie</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>La mairie de Princeton est le point névralgique de la ville.<br />
									Vous devrez obligatoirement vous y rendre dans votre vie citoyenne pour diverses raisons comme lors des élections, votre recensment ou encore
									pour accéder à la salle informatique et à ses nombreux outils de recherche d'emploi.</p>
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
										<div class="panel-heading panel-heading-wiki"><h2>Les élections</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>Toutes les semaines, des élections ont lieux à Princeton.<br />
									Pour y participer, rien de plus simple, direction la mairie ! <br />
									Dans la mezzanine du hall d'entrée, vous trouverez des cabines de vote. Entrez dedans et un menu automatique s'ouvrira en vous proposant le choix des
									candidats. <br />
									A VOS VOTES !</p>
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
										<div class="panel-heading panel-heading-wiki"><h2>Salle informatique</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>Une salle informatique est à votre disposition dans la mairie (ascenseur gauche).<br />
									Cette dernière vous permettra d'accéder à notre wiki mais aussi aux offres d'emplois disponibles sur Princeton !</p>
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
										<div class="panel-heading panel-heading-wiki"><h2>Devenir Maire</h2></div>
									</div>
								</div>
								<div class="panel-body">
									<p>Pour devenir maire vous devrez tout d'abord vous assurer d'avoir atteint ou dépassé le niveau RP 90 (324 000xp).</p>
									<p>Rendez-vous ensuite à la mairie de Princeton (la grande tour entre le commissariat et le bar "le requin") puis appuyez sur votre touche "utiliser" pour ouvrir le menu de la mairie.</p>
									<p>Vous aurez l'option "candidature" et vous pourrez déposer la votre pour 250 000$ RP.</p>
									<p>Va s'en suivre un temps de vote par les joueurs ayant atteint ou dépassé le niveau 30, à vous de trouver le bon moyen de vous faire de la pub !</p>
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
										<div class="panel-heading panel-heading-wiki"><h2>Les amendements</h2></div>
									</div>
								</div>
								<div class="panel-body">
								<h3>Le maire peut mettre en place 4 des amendements ci-dessous :</h3>
									<ul>
										<li><p>Les amendes sont soit augmentées de 5% ou réduites de 10%</p></li>
										<li><p>Le prix des items sont soit augmentés de 10% ou réduits de 5%</p></li>
										<li><p>Les réductions sont interdites</p></li>
										<li><p>La production de machines et plants est accélérée ou ralentie</p></li>
										<li><p>Interdition de faire des braquages</p></li>
										<li><p>Lors des captures du bunker, il peux interdir d'utiliser des items</p></li>
										<li><p>Les payes sont augmentées de 5% ou réduites de 10%</p></li>
										<li><p>L'hôtel des ventes est interdit</p></li>
									</ul>
									<p>Mais attention, chaque amendements ne pourra affecter que un job ou un gang à la fois.</p>
									<p>Le maire à également accès à sa villa personnel, qui lui affecte un bonus de paye et qui subbit les même règles que la villa Immobilier,elle se situe a la fin du tunnel à coté des techniciens.</p>
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
										<div class="panel-heading panel-heading-wiki"><h2>Mode Actif/Passif</h2></div>
									</div>
								</div>
								<div class="panel-body">
                                <h3>Un mode actif/passif est disponible sur le serveur. Il vous permettra d'effectuer des actions rp ou de vous en protéger.</h3>
                                <br />
                                <p>En mode actif :</p>
									<ul>
                                        <li>Avoir accès au radar gratuitement.</li>
                                        <li>Augmentez votre vitalité passivement si vous n'êtes pas afk.</li>
                                        <li>Avoir les bonus job (/build).</li>
                                        <li>Vous gagnez 2$ toutes les 20 secondes avec les machines à faux billets/photocopieuses.</li>
                                        <li>Tuer et être tué.</li>
                                    </ul>
                                    <p>En mode passif :</p>
                                    <ul>
                                        <li>Vous n'aurez pas accès au radar gratuitement.</li>
                                        <li>Votre vitalité ne sera pas augmentée.</li>
                                        <li>Pas d'accès au bonus job (/build).</li>
                                        <li>Vous gagnez 1$ toutes les 20 secondes avec les machines à faux billets/photocopieuses.</li>
                                        <li>Vous ne pourrez être tué à l'exception d'un contrat mercenaire et d'une voiture qui vous renverse.</li>
                                    </ul>
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
							<a href="#GroupA">La Mairie</a>
						</li>
						<li>
							<a href="#GroupB">Les élections</a>
						</li>
						<li>
							<a href="#GroupC">Salle informatique</a>
						</li>
						<li>
							<a href="#GroupD">Devenir Maire</a>
						</li>
						<li>
							<a href="#GroupE">Les amendements</a>
						</li>
						<li>
							<a href="#GroupF">Mode Actif/Passif</a>
						</li>
					</ul>
				</nav>-->
