			<div class="row">
				<div class="col-sm-3 hidden-phone">
					<div class="container">
						<div class="col-sm-3 hidden-phone">
							<div class="panel-group" id="accordion">
							<div class="panel panel-wiki">
						<div class="panel-heading">
							<h4 class="panel-title title-nav">
								<a data-toggle="collapse" data-parent="#accordion" href="#MenuOne"><i class="fa fa-chevron-right" aria-hidden="true"></i>
								Liste des jobs</a>
							</h4>
						</div>
						<div id="MenuOne" class="panel-collapse collapse">
							<ul class="list-group">
								<li class="list-group-item"><a href="#GroupBSub1">Armurier</a></li>
								<li class="list-group-item"><a href="#GroupBSub2">L'agence immobilière</a></li>
								<li class="list-group-item"><a href="#GroupBSub3">Artificier</a></li>
								<li class="list-group-item"><a href="#GroupBSub4">Artisan</a></li>
								<li class="list-group-item"><a href="#GroupBSub5">Banquier</a></li>
								<li class="list-group-item"><a href="#GroupBSub6">Concessionnaire</a></li>
								<li class="list-group-item"><a href="#GroupBSub7">Coach</a></li>
								<li class="list-group-item"><a href="#GroupBSub8">L'hôpital</a></li>
								<li class="list-group-item"><a href="#GroupBSub9">Casino</a></li>
								<li class="list-group-item"><a href="#GroupBSub10">Mc Donald's</a></li>
								<li class="list-group-item"><a href="#GroupBSub11">Sex-shop</a></li>
								<li class="list-group-item"><a href="#GroupBSub12">Technicien</a></li>
								<li class="list-group-item"><a href="#GroupCSub1">La Justice</a></li>
								<li class="list-group-item"><a href="#GroupCSub2">Les avocats</a></li>
								<li class="list-group-item"><a href="#GroupCSub3">La police</a></li>
								<li class="list-group-item"><a href="#GroupDSub1">La mafia Cosa Nostra</a></li>
								<li class="list-group-item"><a href="#GroupDSub2">Mercenaire</a></li>
								<li class="list-group-item"><a href="#GroupDSub3">La Stidda Famiglia</a></li>
							</ul>
						</div>
					</div>
							<div ng-include="'/templates/tpl/aide/menu.tpl'"></div>			
							</div>
						</div>
					</div>
				</div>	
				<div class="col-xs-12 col-sm-9">
						<br /><br />
						<center><img alt="img_title" id="img_title" src="/images/wiki/job/job_top.png"></center><br />
						<br />
						<div class="row">
							<div id="GroupA" class="col-md-12 group">
								<div class="panel panel-wiki">
									<div class="row">
										<div class="hidden-xs hidden-sm col-md-1">
											<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span>
										</div>
										<div class="col-md-11">
											<div class="panel-heading panel-heading-wiki"><h2>Conseils</h2></div>
										</div>
									</div>
									<div class="panel-body">
										<ol>
											<li><p id="GroupASub1">Dans un premier temps, vous pourrez postuler pour n'importe quel emploi <a target="_blank" href="https://www.ts-x.eu/forum/viewforum.php?f=35">sur notre forum</a>.<br />
											Il vous suffit de rechercher l'offre de recrutement du métier dans lequel vous désirez travailler (n'hésitez pas à déposer deux ou trois offres de métiers différentes, cela augmentera vos chances). <br />
											Pour faire une belle candidature, inspirez-vous de celles précédemment faites sans faire de copier / coller.</p></li>
											<br />
											<li><p id="GroupASub2">Si vous avez de la chance ou des contacts, vous pourrez aussi trouver un emploi directement en jeu.<br />
											Vous pouvez également utiliser la commande /job et contacter le chef ou un co-chef du métier qui vous intéresse s'ils sont connectés.<br />
											Encore plus simple, faites un message correct et simple dans le chat global en demandant si un chef recrute. Si un co-chef ou un chef est présent, il vous répondra et vous présentera son métier si vous correspondez à ses attentes.</p></li>
											<br />
										</ol>
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
											<div class="panel-heading panel-heading-wiki"><h2>Les métiers de ventes</h2></div>
										</div>
									</div>
									<div class="panel-body">
										<p>Dans la ville de Princeton, il existe 12 commerces différents qui recherchent activement des employés pour répondre aux attentes de leurs clients. Serez-vous à la hauteur ?</p>
										<br /><br />
										<img id="GroupBSub1" alt="armurier" class="img_wiki radius" src="/images/wiki/job/armu.jpg" />
										<div ng-include="'/templates/tpl/aide/job/111.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										&nbsp;<br /><br />
										<img id="GroupBSub2" alt="agence_immo" class="img_wiki radius" src="/images/wiki/job/immo.jpg" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/61.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
										&nbsp;<br /><br />
										<img id="GroupBSub3" alt="artificier" class="img_wiki radius" src="/images/wiki/job/artif.jpg" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/131.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
										&nbsp;<br /><br />
										<img id="GroupBSub4" alt="artisan" class="img_wiki radius" src="/images/wiki/job/arti.jpg" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/31.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
										&nbsp;<br /><br />
										<img id="GroupBSub5" alt="banquier" class="img_wiki radius" src="/images/wiki/job/bank.jpg" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/211.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
										&nbsp;<br /><br />
										<img id="GroupBSub6" alt="carshop" class="img_wiki radius" src="/images/wiki/job/cars.jpg" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/51.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
										&nbsp;<br /><br />
										<img id="GroupBSub7" alt="coach" class="img_wiki radius" src="/images/wiki/job/coach.jpg" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/71.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
										&nbsp;<br /><br />
										<img id="GroupBSub8" alt="hopital" class="img_wiki radius" src="/images/wiki/job/hp.jpg" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/11.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
										&nbsp;<br /><br />
										<img id="GroupBSub9" alt="loto" class="img_wiki radius" src="/images/wiki/job/loto.jpg" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/171.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
										&nbsp;<br /><br />
										<img id="GroupBSub10" alt="mcdo" class="img_wiki radius" src="/images/wiki/job/mcdo.jpg" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/21.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
										&nbsp;<br /><br />
										<img id="GroupBSub11" alt="sexshop" class="img_wiki radius" src="/images/wiki/job/sex.png" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/191.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
										&nbsp;<br /><br />
										<img id="GroupBSub12" alt="mercenaire" class="img_wiki radius" src="/images/wiki/job/tech.png" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/221.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
										<br /><br />
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
											<div class="panel-heading panel-heading-wiki"><h2>Les forces de l'ordre</h2></div>
										</div>
									</div>
									<div class="panel-body">
										<br /><br />
										<img id="GroupCSub1" alt="tribu" class="img_wiki radius" src="/images/wiki/job/tribu.jpg" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/101.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
										&nbsp;<br /><br />
										<img id="GroupCSub2" alt="avocat" class="img_wiki radius" src="/images/wiki/job/avoc.jpg" />
										<br /><br />
										<p>Ce métier annexe vous offre l'occasion de défendre une victime ou un accusé pendant un procès.<br />
										Si défendre la veuve et le meurtrier vous inspire,<a href="https://www.ts-x.eu/forum/viewtopic.php?f=35&t=33602&view=unread#unread"> c'est par ici !</a></p>
										<br />
										<p></p>
										&nbsp;<br /><br />
										<img id="GroupCSub3" alt="police" class="img_wiki radius" src="/images/wiki/job/police.jpg" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/1.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
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
											<div class="panel-heading panel-heading-wiki"><h2>Les hors la loi</h2></div>
										</div>
									</div>
									<div class="panel-body">
										<br /><br />
										<img id="GroupDSub1" alt="mafia" class="img_wiki radius" src="/images/wiki/job/mafia.jpg" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/91.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
										&nbsp;<br /><br />
										<img id="GroupDSub2" alt="mercenaire" class="img_wiki radius" src="/images/wiki/job/merco.jpg" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/41.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
										&nbsp;<br /><br />
										<img id="GroupDSub3" alt="stidda" class="img_wiki radius" src="/images/wiki/job/stidda.jpg" />
										<br /><br />
										<div ng-include="'/templates/tpl/aide/job/81.tpl'"><i ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-5x"></i></div>
										<br />
										<p></p>
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
											<div class="panel-heading panel-heading-wiki"><h2>Devenir chef d'un métier</h2></div>
										</div>
									</div>
									<div class="panel-body">
										<p class=" text-center blood"><u>Une place de chef est disponible SEULEMENT quand KoSSoLax le signale sur le topic !</u></p>
										<br /><br /><br />
										<p>Pour devenir chef d'un métier, vous devrez remplir certaines conditions :</p>
										<br />
										<ul>
											<li>Avoir le no-pyj</li>
											<li>Être présent dans le job depuis quelques temps</li>
											<li>Avoir au minimum 7h/semaine de jeu.</li>
											<li>Avoir 100 000$</li>
										</ul>
										<br />
										<p>Lorsque vous obtenez la place, vous vous engagez pour une période de 3 mois, vous devez, dès lors:</p>
										<br />
										<ul>
											<li>Respecter votre quota d'engagement (profitez du système de parrainage...)</li>
											<li>Continuer à être actif</li>
											<li>S'occuper au bon fonctionnement, exposer les problèmes sur le forum et rechercher des solutions</li>
										</ul>
										<br />
										<p>Si vous devez vous absenter pour de bonnes raisons (vacance, déménagement, etc), envoyez-moi un mail ou un MP sur le forum précisant bien qui vous êtes et pour quel job.<br />
										Vous devez prendre aussi les dispositions nécessaires: Un de vos co-chef doit s'occuper du quota.</p>
										<br />
										<p>Vous vous engagez pour 3 mois au minimum, si vous quittez avant vous risquez les sanctions suivantes:</p>
										<br />
										<ul>
											<li>Démission la première semaine : Ban du serveur.</li>
											<li>Démission le premier mois : Perte du nopyj pour 31 jours.</li>
											<li>Démission pendant le 2ème mois : Forte pénalité pour devenir chef d'un nouveau job.</li>
											<li>Démission pendant le 3ème mois : Légère pénalité pour de devenir chef d'un nouveau job.</li>
										</ul>
										<br />
										<p>Enfin, vous devez impérativement marquer dans votre candidature que vous avez lu le code du travail, et ne pas dépasser les 5 lignes !<br />
										À partir du moment où vous avez été accepté, vous avez 48 heures pour marquer "Lu et approuvé" sur ce topic,
										sans quoi... Vous perdez votre place de chef.</p>
										<br /><br /><br />
										<div class="row">
											<div class="col-sm-offset-3 col-sm-2">
												<a href="https://www.ts-x.eu/forum/viewtopic.php?f=10&t=33213" target="_blank" class="btn btn-warning" role="button">Le Code du Travail</a>
											</div>
											<div class="col-sm-offset-1 col-sm-2">
												<a href="https://www.ts-x.eu/forum/viewtopic.php?f=155&t=27256&view=unread#unread" target="_blank" class="btn btn-success" role="button">Devenir Chef</a>
											</div>
										</div>
										<br /><br /><br />
										<p class=" text-center blood"><u>Une place de chef est disponible SEULEMENT quand KoSSoLax le signale sur le topic !</u></p>
									</div>
								</div>
							</div>
						</div>
					</div>
			</div>