<div ng-controller="ctrlTabs" data-job="81">
	<ul class="nav nav-tabs" role="tablist">
		<li><a ng-click="tabs='desc'" ng-class="tabs=='desc'? 'active' : ''">Présentation </a></li>
		<li><a ng-click="tabs='memb'" ng-class="tabs=='memb'? 'active' : ''">Employés </a></li>
		<li><a ng-click="tabs='hier'" ng-class="tabs=='hier'? 'active' : ''">Hiérarchie </a></li>
		<li><a ng-click="tabs='note'" ng-class="tabs=='note'? 'active' : ''">Shownote </a></li>
		<li><a ng-click="tabs='item'" ng-class="tabs=='item'? 'active' : ''">Boutique </a></li>
		<li><a ng-click="tabs='drogs'" ng-class="tabs=='drogs'? 'active' : ''">Drogues </a></li>
		<li><a ng-click="tabs='quest'" ng-class="tabs=='quest'? 'active' : ''">Quêtes </a></li>
	</ul>

	<div class="tab-content" style="width:100%;">
		<div role="tabpanel" class="tab-pane active" ng-show="tabs=='desc'">
					<hr class="featurette-divider">
					<h2 class="text-center">Qui sommes-nous :</h2><br />
					<hr class="featurette-divider">
					<p>La Stidda Famiglia est la famille la plus respectée de Princeton, pas comme les rebuts de la Cosa Nostra.<br />
					Nous sommes une petite entreprise de fleuristes qui ne se laisse pas marcher sur les pieds !</p>
					<hr class="featurette-divider">
					<h2 class="text-center">Informations :</h2><br />
					<hr class="featurette-divider">
					<p><u>Siè</u>g<u>e social :</u> Ruelle sombre.</p><br/>
					<p><u>Distinctions :</u> Meilleurs fleuristes de l'année depuis maintenant 8 ans !</p>
				
					<hr class="featurette-divider">
					<h2 class="text-center">Recrutement :</h2><br />
					<hr class="featurette-divider">
					<p>Si vous aimez les plantes et que vous avez du sang de Gitan dans les veines, alors bienvenue chez nous !</p>
					<br />
					<center><a href="https://www.ts-x.eu/forum/viewforum.php?f=35" class="btn btn-md btn-success"><i class="fa fa-user"></i> Déposez une candidature spontanée</a></center>
					<br />
		</div>
		<div role="tabpanel" class="tab-pane active" ng-show="tabs=='memb'">
			<h2 class="text-center"><u>Liste des em</u>p<u>lo</u>y<u>és :</u></h2><br /><br />
			<i ng-hide="users" ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-{{i}}x"></i>
			<table width="60%" class="table-condensed employes">
				<tbody>
					<tr>
						<th class="text-center"><h3>Poste occupé :</h3></th>
						<th><h3>Noms :</h3></th>
					</tr>
					<tr ng-repeat="user in users">
						<th class="text-center"><span style="color: #003f75;">{{user.name}} </span></th>
						<th><span style="color: #999;">{{user.nick}}</span></th>
					</tr>
				</tbody>
			</table><br />
		</div>
		<div role="tabpanel" class="tab-pane active" ng-show="tabs=='hier'">
			 <h2 class="text-center"><u>La hiérarchie de l'entre</u>p<u>rise :</u></h2><br />
			  <i ng-hide="jobs" ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-{{i}}x"></i>
				<table width="40%" class="table-condensed hierarchie">
					<tbody>
						<tr>
							<th>Rang:</th>
							<th>Paye:</th>
						</tr>
						<tr ng-repeat="job in jobs.sub" ng-if="job.id!=0">
							<th><span style="color: #003f75;">{{job.name}} </span></th>
							<th><span style="color: green;">{{job.pay}} $rp</span></th>
						</tr>
					</tbody>
				</table><br />
				<p class="text-center"> Nous avons actuellement {{jobs.quota}} fleuristes réguliers dans  notre entreprise.</p>
		</div>
		<div role="tabpanel" class="tab-pane active" ng-show="tabs=='note'">
			<h2 class="text-center"><u>Le rè</u>g<u>lement interne :</u></h2><br />
			<i ng-hide="jobs" ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-{{i}}x"></i>
			<ul>
				<li ng-repeat="note in jobs.notes"><span style="color: #999;">{{note.name}}</span></li>
			</ul><br />
		</div>
		<div role="tabpanel" class="tab-pane active" ng-show="tabs=='item'">
			<h2><u>Nos Produits :</u></h2><br /><br />
			<i ng-hide="items" ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-{{i}}x"></i>
			<span ng-repeat="item in items" rp-item-information="{{item.id}}"></span><br />
		</div>
		<div role="tabpanel" class="tab-pane active" ng-show="tabs=='drogs'">
					<table class="table-condensed">
					<div class="row">
						<div class="col-md-3">
							<img width="100" height="75"
							src="/images/wiki/job/drogs/cocaine.png" data-toggle="popover"
							data-placement="top" title="" data-content="Augmente votre vie à 500 HP."
							data-original-title="Cocaïne" />
						</div>
						<div class="col-md-3">
							<img width="100" height="75"
							src="/images/wiki/job/drogs/heroine.png" data-toggle="popover"
							data-placement="top" title="" data-content="Permet d'augmenter temporairement votre vitesse."
							data-original-title="Héroïne" />
						</div>
						<div class="col-md-3">
							<img width="100" height="75"
							src="/images/wiki/job/drogs/champignon.png" data-toggle="popover"
							data-placement="top" title="" data-content="Vous fais planner GRAVE ! (réduit votre gravité)."
							data-original-title="Champignon" />
						</div>
						<div class="col-md-3">
							<img width="100" height="75"
							src="/images/wiki/job/drogs/crystal.png" data-toggle="popover"
							data-placement="top" title="" data-content="Vous donne 500HP et vous fais planner (réduit votre gravité)."
							data-original-title="Cristal" />
						</div>
					</div>
					<div class="row">
						<div class="col-md-offset-2 col-md-3">
							<img width="100" height="75"
							src="/images/wiki/job/drogs/pcp.png" data-toggle="popover"
							data-placement="top" title="" data-content="Réduit la vue de votre cible."
							data-original-title="PcP" />
						</div>
						<div class="col-md-3">
							<img width="100" height="75"
							src="/images/wiki/job/drogs/lsd.png" data-toggle="popover"
							data-placement="top" title="" data-content="Ralentis votre cible."
							data-original-title="LSD" />
						</div>
						<div class="col-md-3">
							<img width="100" height="75"
							src="/images/wiki/job/drogs/cannabis.png" data-toggle="popover"
							data-placement="top" title="" data-content="Devenez invisible en étant accroupi."
							data-original-title="Cannabis" />
						</div>
					</div>
					<div class="row">
						<div class="col-md-3">
							<img width="100" height="75"
							src="/images/wiki/job/drogs/crack.png" data-toggle="popover"
							data-placement="top" title="" data-content="Réduit vos dégats reçu de 70%."
							data-original-title="Crack" />
						</div>
						<div class="col-md-3">
							<img width="100" height="75"
							src="/images/wiki/job/drogs/ecstasy.png" data-toggle="popover"
							data-placement="top" title="" data-content="Augmente votre vie de 300 HP et votre kevlar de 120."
							data-original-title="Ecstasy" />
						</div>
						<div class="col-md-3">
							<img width="100" height="75"
							src="/images/wiki/job/drogs/ghb.png" data-toggle="popover"
							data-placement="top" title="" data-content="Double vos dégâts et vous permet de tuer sans être inquiéter par la police."
							data-original-title="GHB" />
						</div>
						<div class="col-md-3">
							<img width="100" height="75"
							src="/images/wiki/job/drogs/beuh.png" data-toggle="popover"
							data-placement="top" title="" data-content="Augmente votre vie à 300 HP et vous fait planner (réduit votre gravité)."
							data-original-title="Beuh" />
						</div>
					</div>
						
			</table><br />
		</div>
		<div role="tabpanel" class="tab-pane active" ng-show="tabs=='quest'">
			<h2>Nos missions :</h2><br />
			<table class="table-condensed">
				<tbody>
					<tr>
						<td><h3 class="ocean">Nom de la quête</h3></td>
						<td><h3 class="pomme">Gain </h3></td>
						<td><h3 class="prune">Objectif :</h3></td>
					</tr>
					<tr>
						<td>Vandalisme des distributeurs</td>
						<td>2.000$RP</td>
						<td>Crochetez tous les distributeurs présents dans les stations de métro.</td>
					</tr>
					<tr>
						<td>Surveillance des plants</td>
						<td>500$RP par plan restant</td>
						<td>Posez 10 plants et protégez-les pendant 24 minutes.</td>
					</tr>
					<tr>
						<td>Blanchiment d'argent</td>
						<td>5.000$RP</td>
						<td>Volez une arme à un flic et ramenez-la dans votre planque.</td>
					</tr>
					<tr>
						<td>Récolte des plants</td>
						<td>1.000$ par plant</td>
						<td>Crochetez 5 fois la place de l'indépendance en 5x6 minutes.</td>
					</tr>
					<tr>
						<td>Razzia</td>
						<td>En fonction des armes volées</td>
						<td>Introduisez-vous dans le commissariat jusqu'au distributeur d'armes <br />
						et en voler le plus possible, ou bien allez crocheter le marché noir de la mafia !</td>
					</tr>
				</tbody>
			</table><br />
		</div>
	</div>
</div>
