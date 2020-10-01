<script type="text/javascript">
	_app.controller('sondage', function($scope) {
	    $scope.step = 0;
	    $scope.restart = function() {
			location.href = "/index.php?page=sondage";
		}
	});
</script>
<style>
	#sondage_form > div, #sondage_form > div > div {
		font-size: 14px;
		color: white;
	}
	.form-group > label {
		text-align: center;
		margin: auto;
	}
</style>
<form role="form" class="form-inline col-sm-offset-1 col-sm-11" action="index.php?page=sondage&action=post" method="post" id="sondage_form" ng-controller="sondage" >
	<input type="hidden" name="target" value="{$admin.steamid}" />
	<img src="/images/sondage.png" style="width:100%" />
	<br clear="all" />
	<div class="row" ng-show="step==0">
		<p class="col-sm-11 col-sm-offset-1"><br><br>
        	En 7 années d'existence, notre serveur n'a pas cessé d'évoluer et de s'améliorer.<br />
		Des nouveautés sortent chaque semaine sur le serveur et ce qui le rend unique, <br />
		mais nous ne souhaitons pas nous arrêter là et nous espérons vivre encore quelques années de plus à vos côtés.
		<br /><br /><br />
		
		<h3>Connaissez-vous notre {$admin.rank} {$admin.name}?</h3>
		<div class="form-group col-sm-12" ng-show="step==0">
			<label class="col-sm-3"><input type="radio" name="q0" value="1" ng-click="step=1" /> Oui</label>
			<label class="col-sm-3"><input type="radio" name="q0" value="0"  ng-click="restart()"/> Non</label>
		</div>
		<br /><br /><br />
		Ce sondage vous prendra 5 minutes pour y répondre et est anonyme.</p>
		<br /><br /> 
	</div>
	<div class="row" ng-show="step>=1 && step < 10"> 
		<h3>Concernant les events de notre {$admin.rank} {$admin.name}</u></h3>
		<div class="form-group col-sm-12" ng-show="step==1"> 
			<div class="col-sm-12">Avez-vous déjà vu ou participé à un event conçu par {$admin.name}?</div>
			<label class="col-sm-3"><input type="radio" name="q1" value="1" ng-click="step=2" /> Oui</label>
			<label class="col-sm-3"><input type="radio" name="q1" value="0"  ng-click="step=11"/> Non</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==2">
			<div class="col-sm-12">Pensez-vous que les évents de {$admin.name} sont intéressants?</div>
			<label class="col-sm-2"><input type="radio" name="q2" value="0" ng-click="step=3">Pas du tout d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q2" value="1" ng-click="step=3">Plutôt pas d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q2" value="2" ng-click="step=11">Neutre</label>
			<label class="col-sm-2"><input type="radio" name="q2" value="3" ng-click="step=11">Plutôt d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q2" value="4" ng-click="step=11">Totalement d'accord</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==3">
			<div class="col-sm-12">Comment {$admin.name} pourrait-il faire de meilleurs events?</div>
			<label class="col-sm-4"><input type="radio" name="q3" value="0" ng-click="step=11">Plus les travailler</label>
			<label class="col-sm-4"><input type="radio" name="q3" value="1" ng-click="step=11">Mieux les encadrer</label>
			<label class="col-sm-4"><input type="radio" name="q3" value="2" ng-click="step=11">Varier les events</label>
		</div>
	</div>
	
	<div class="row" ng-show="step>=10 && step < 20">
		<h3>Concernant l'administration de notre {$admin.rank} {$admin.name}</u></h3>
		<div class="form-group col-sm-12" ng-show="step==11"> 
			<div class="col-sm-12">Avez-vous déjà vu ou reçu une sanction de la part de {$admin.name}?</div>
			<label class="col-sm-4"><input type="radio" name="q11" value="1" ng-click="step=12" /> Oui, j'en ai déjà vue</label>
			<label class="col-sm-4"><input type="radio" name="q11" value="2" ng-click="step=12" /> Oui, j'en ai déjà reçue</label>
			<label class="col-sm-4"><input type="radio" name="q11" value="0"  ng-click="step=21"/> Non, j'en ai jamais reçue ni vue</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==12">
			<div class="col-sm-12">Pensez-vous que les sanctions de {$admin.name} sont elles justes?</div>
			<label class="col-sm-2"><input type="radio" name="q12" value="0" ng-click="step=13">Pas du tout d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q12" value="1" ng-click="step=13">Plutôt pas d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q12" value="2" ng-click="step=21">Neutre</label>
			<label class="col-sm-2"><input type="radio" name="q12" value="3" ng-click="step=21">Plutôt d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q12" value="4" ng-click="step=21">Totalement d'accord</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==13">
			<div class="col-sm-12">Comment {$admin.name} pourrait-il faire des sanctions plus justes?</div>
			<label class="col-sm-4"><input type="radio" name="q13" value="0" ng-click="step=21">Réfléchir au contexte avant de sanctionner</label>
			<label class="col-sm-4"><input type="radio" name="q13" value="1" ng-click="step=21">Plus de gag/mute et moins de kick/ban</label>
		</div>
	</div>
	
	<div class="row" ng-show="step>=20 && step < 30">
		<h3>Concernant l'activité de notre {$admin.rank} {$admin.name}</u></h3>
		<div class="form-group col-sm-12" ng-show="step==21">
			<div class="col-sm-12">Pensez-vous que {$admin.name} règle-t-il suffisamment les problèmes du quotidien?</div>
			<label class="col-sm-2"><input type="radio" name="q21" value="0" ng-click="step=22">Pas du tout d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q21" value="1" ng-click="step=22">Plutôt pas d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q21" value="2" ng-click="step=22">Neutre</label>
			<label class="col-sm-2"><input type="radio" name="q21" value="3" ng-click="step=22">Plutôt d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q21" value="4" ng-click="step=22">Totalement d'accord</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==22">
			<div class="col-sm-12">Pensez-vous que {$admin.name} est-il suffisamment disponible?</div>
			<label class="col-sm-2"><input type="radio" name="q22" value="0" ng-click="step=23">Pas du tout d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q22" value="1" ng-click="step=23">Plutôt pas d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q22" value="2" ng-click="step=23">Neutre</label>
			<label class="col-sm-2"><input type="radio" name="q22" value="3" ng-click="step=23">Plutôt d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q22" value="4" ng-click="step=23">Totalement d'accord</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==23">
			<div class="col-sm-12">Pensez-vous que {$admin.name} s'implique-t-il suffisamment pour faire progresser le serveur?</div>
			<label class="col-sm-2"><input type="radio" name="q23" value="0" ng-click="step=24">Pas du tout d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q23" value="1" ng-click="step=24">Plutôt pas d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q23" value="2" ng-click="step=24">Neutre</label>
			<label class="col-sm-2"><input type="radio" name="q23" value="3" ng-click="step=24">Plutôt d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q23" value="4" ng-click="step=24">Totalement d'accord</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==24">
			<div class="col-sm-12">Pensez-vous que {$admin.name} fait-il du bon boulot?</div>
			<label class="col-sm-2"><input type="radio" name="q24" value="0" ng-click="step=31">Pas du tout d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q24" value="1" ng-click="step=31">Plutôt pas d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q24" value="2" ng-click="step=31">Neutre</label>
			<label class="col-sm-2"><input type="radio" name="q24" value="3" ng-click="step=31">Plutôt d'accord</label>
			<label class="col-sm-2"><input type="radio" name="q24" value="4" ng-click="step=31">Totalement d'accord</label>
		</div>
	</div>
	
	<div class="row" ng-show="step>=30 && step < 40">
		<h3>Globalement comment évalueriez-vous notre {$admin.rank} {$admin.name}?</u></h3>
		<div class="form-group col-sm-12" ng-show="step==31">
			<div class="col-sm-12">Si vous deviez mettre une note sur 10 à {$admin.name}, combien lui donneriez vous?</div>
			<label class="col-sm-1"><input type="radio" name="q31" value="1" ng-click="step=32">1</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="2" ng-click="step=32">2</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="3" ng-click="step=32">3</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="4" ng-click="step=32">4</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="5" ng-click="step=32">5</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="6" ng-click="step=40">6</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="7" ng-click="step=40">7</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="8" ng-click="step=40">8</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="9" ng-click="step=40">9</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="10" ng-click="step=40">10</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==32">
			<div class="col-sm-12">Comment {$admin.name} pourrait-il améliorer sa note?</div>
			<textarea class="form-control col-sm-offset-3" name="q32" style="width:50% !important;"></textarea>
			<a class="btn btn-success" ng-click="step=40">Suivant</a>
		</div>
	</div> 

	<div class="row" ng-show="step==40">
		<p class="col-sm-6 col-sm-offset-3"><br /><br />
			Merci pour le temps que vous avez consacré à répondre à ce sondage !<br />
			<a class="btn btn-danger" ng-click="step=0">Recommencer le sondage</a> ou
			<input type="submit" class="btn btn-success" value="Envoyer mes réponses" />
			<br /><br /><br /><br />
		</p>
	</div>
	<div class="row">
		<br /><br /><br /> 
		<div class="progress" ng-hide="step==0"><div class="progress-bar" role="progressbar" aria-valuenow="{{step/40*100}}" aria-valuemin="0" aria-valuemax="100" style="width: {{step/40*100}}%;">{{step/40*100 | number: 0}}%</div></div>

	</div>
</form>
