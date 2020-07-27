<div ng-controller="rpSuccess">
	<h2 ng-show="isValidUser">Liste des succès de {{ user.name }}</h2>
	<h2 ng-show="!isValidUser">Liste des succès</h2>

	<div class="container-fluid">
	<div class="row" ng-repeat="success in list" style="margin-bottom: 15px; border: 1px solid darkgray; border-radius: 3px;">
		<img style="float: left; height: 128px; width: 128px; margin-right: 10px;" src="./images/success_v2/{{success.id}}.jpg">

		<div class="content-heading" style="padding-top: 10px;">
			<h3 style="font-size: 25px; letter-spacing: 1px;">{{ success.name }}</h3>
		</div>
		<p style="margin-top: 8px; font-size: 15px">{{ success.desc }}</p>

		<div ng-show="isValidUser" class="progress" style="margin-top: 16px;margin-bottom: 16px;">
  			<div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="{{ success.progress }}" aria-valuemin="0" aria-valuemax="100" style="width: {{ success.progress }}%;">

  				<font color="black">{{success.count_to_unlock}} / {{success.need_to_unlock}} ({{success.progress}}%)</font>
  			</div>
		</div>

		<div ng-show="isValidUser">
			<p ng-show="success.count_to_unlock == success.max && success.max > 0">Terminé !</p>
			<p ng-show="success.achieved > 0" style="color: green">Vous avez accomplis ce succès {{ success.achieved }} fois</p>
			<p ng-show="success.last_achieved > 0"><b>Dernier accomplissement le {{ success.last_achieved | date: 'dd-MM-yyyy'}}</b></p>
			<p ng-show="success.last_achieved <= 0 || success.count_to_unlock == 0" style="color: red">Vous n'avez jamais accomplis ce succès</p>
		</div>
	 </div>
	</div>
</div>