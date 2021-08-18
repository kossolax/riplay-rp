<div ng-controller="ctrlTabs" data-job="91">
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
					<p>La Cosa Nostra est la famille la plus respectée de Princeton. Voler aux riches pour donner aux pauvres n'est 
					pas du tout notre devise.<br />
					Seul notre profit personnel compte !</p>
					<hr class="featurette-divider">
					<h2 class="text-center">Informations :</h2><br />
					<hr class="featurette-divider">
					<p><u>Siè</u>g<u>e social :</u> Rue de la soif</p><br/>
					<p><u>Distinctions :</u> Ennemis Publique N°1 depuis plus de 5 ans, souvent imités mais jamais égalés !</p>
				
					<hr class="featurette-divider">
					<h2 class="text-center">Recrutement :</h2><br />
					<hr class="featurette-divider">
					<p>Nous sommes des hommes d'honneur, toute personne ayant un passé d'hors la loi est la bienvenue chez nous.<br />
					Escrocs, assassins et voleurs, nos portes vous sont ouvertes.</p>
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
				<p class="text-center"> Nous avons actuellement {{jobs.quota}} mafieux réguliers dans  notre entreprise.</p>
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
						<td>Délivrance</td>
						<td>1.000$RP par prisonnier</td>
						<td>Infiltrez-vous dans la prison et libérez un maximum de prisonniers.</td>
					</tr>
					<tr>
						<td>Où est Charlie?</td>
						<td>1.000$RP par zone découverte</td>
						<td>Rendez-vous dans 5 zones aléatoires de la ville.</td>
					</tr>
					<tr>
						<td>Documents secrets</td>
						<td>5.000$RP</td>
						<td>Rendez-vous dans la villa PvP pour voler des documents secrets <br />
						et retournez dans votre planque pour les déposer.</td>
					</tr>
					<tr>
						<td>Trafic illégal</td>
						<td>5.000$RP</td>
						<td>Introduisez-vous dans le commissariat jusqu'au distributeur d'armes<br />
						et volez-en le plus possible !</td>
					</tr>
					<tr>
						<td>Braquage des distributeurs</td>
						<td>2.500$RP</td>
						<td>Crochetez tous les distributeurs présents dans les stations de métro.</td>
					</tr>
				</tbody>
			</table><br />
		</div>
	</div>
</div>
