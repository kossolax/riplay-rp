<div ng-controller="ctrlTabs" data-job="131">
	<ul class="nav nav-tabs" role="tablist">
		<li><a ng-click="tabs='desc'" ng-class="tabs=='desc'? 'active' : ''">Présentation </a></li>
		<li><a ng-click="tabs='memb'" ng-class="tabs=='memb'? 'active' : ''">Employés </a></li>
		<li><a ng-click="tabs='hier'" ng-class="tabs=='hier'? 'active' : ''">Hiérarchie </a></li>
		<li><a ng-click="tabs='note'" ng-class="tabs=='note'? 'active' : ''">Shownote </a></li>
		<li><a ng-click="tabs='item'" ng-class="tabs=='item'? 'active' : ''">Boutique </a></li>
		<li><a ng-click="tabs='quest'" ng-class="tabs=='quest'? 'active' : ''">Quêtes </a></li>
	</ul>

	<div class="tab-content" style="width:100%;">
		<div role="tabpanel" class="tab-pane active" ng-show="tabs=='desc'">
					<hr class="featurette-divider">
					<h2 class="text-center">Qui sommes-nous :</h2><br />
					<hr class="featurette-divider">
					<p>Fondé en 2007, nous avons très vite conquis le marché militaire et public.<br />
					Notre entreprise est connue pour ses feux d'artifice annuel mais aussi pour son ingéniosité quant à la conception des explosifs.</p>
					<hr class="featurette-divider">
					<h2 class="text-center">Informations :</h2><br />
					<hr class="featurette-divider">
					<p><u>Siè</u>g<u>e social :</u> Ruelle sombre.</p><br/>
					<p><u>Portefeuille de propriété intellectuelle :</u> Des dizaines de brevets axés sur les technologies d'armement chimique pour l'armée.</p><br />
					<p><u>Distinctions :</u> En 2016, notre entreprise a reçu le prix de "Meilleur feu d'artifice de l'année" pour la 8ème année consécutive !
				
					<hr class="featurette-divider">
					<h2 class="text-center">Recrutement :</h2><br />
					<hr class="featurette-divider">
					<p>Nous sommes actuellement à la recherche de chimistes amateurs ou expérimentés dans la concoction de feux d'artifice.<br />
					La mairie nous ayant confié un contrat d'exclusivité sur l'armement et l'animation de la ville, nous avons besoin de beaucoup de personnel !</p>
					<br />
					<center><a href="https://www.ts-x.eu/forum/viewforum.php?f=35" class="btn btn-md btn-success"><i class="fa fa-user"></i> Déposez une candidature spontanée</a></center>
					<br />
		</div>
		<div role="tabpanel" class="tab-pane active" ng-show="tabs=='memb'">
			<h2 class="text-center"><u>Liste des emplo</u>y<u>és :</u></h2><br /><br />
			<i ng-hide="users" ng-repeat="i in [5,4,3,2,1]" class="fa fa-cog fa-spin fa-{{i}}x"></i>
			<table width="60%" class="table-condensed employes">
				<tbody><!-- methode un peut dégueux pour centrer, a revoir vite ! -->
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
				<p class="text-center"> Nous avons actuellement {{jobs.quota}} vendeurs réguliers dans  notre entreprise.</p>
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
						<td>Collecte des matières premières</td>
						<td>[PvP] AK-47</td>
						<td>Votre patron vous demande de récupérer 5 colis en ville le plus vite possible.</td>
					</tr>
					<tr>
						<td>Employé modèle</td>
						<td>1 000$ + 2 500 xp</td>
						<td>Vendez pour 10 000$ de marchandise en 24h</td>
					</tr>
				</tbody>
			</table><br />
		</div>
	</div>
</div>
