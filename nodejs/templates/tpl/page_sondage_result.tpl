<script type="text/javascript">
	var position = new Array();
	function displayQuestion(that, id1) {
		if( position[id1] === undefined )
			position[id1] = 0;
		$.ajax({
			type: "GET",
			url: "/index.php?page=sondage&action=ind&q="+id1+"&v="+position[id1]+"&target={$admin.steamid}",
			cache: true,
			success: function(res) {
				$(that).parent().find("textarea").val( res );
				position[id1]++;
			}
		});
	}
</script>
<style>

span.sres {
	text-decoration: underline;
	color: white;
}
.form-group {
	margin-top: 20px;
}
</style>
<form role="form" class="form-inline col-sm-offset-1 col-sm-11" action="index.php" method="get" id="sondage_form" ng-controller="sondage" >
	<img src="/images/sondage.png" style="width:100%" />
	<br clear="all" />
	<div class="row" ng-show="step==0">
		<div class="form-group col-sm-12" ng-show="step==0"> 
			<select name="target">
			{loop="$admins"}
				<option value="{$key}" {if="$key == $admin.steamid"}selected{/if}>{$value}</option>
			{/loop}
			</select>
			
			<input type="hidden" name="page" value="sondage" />
			<input type="hidden" name="action" value="result" />
			<input type="submit">
		</div>
	</div>
	<div class="row" ng-show="step>=1 && step < 10"> 
		<h3>Concernant les events de notre {$admin.rank} {$admin.name}</u></h3>
		<div class="form-group col-sm-12" ng-show="step==1"> 
			<div class="col-sm-12">Avez-vous déjà vu ou participé à un event conçu par {$admin.name}?</div>
			<label class="col-sm-3"><input type="radio" name="q1" value="1" ng-click="step=2" /> Oui {$q1at1}</label>
			<label class="col-sm-3"><input type="radio" name="q1" value="0"  ng-click="step=11"/> Non {$q1at0}</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==2">
			<div class="col-sm-12">Pensez-vous que les évents de {$admin.name} sont intéressants?</div>
			<label class="col-sm-2"><input type="radio" name="q2" value="0" ng-click="step=3">Pas du tout d'accord {$q2at0}</label>
			<label class="col-sm-2"><input type="radio" name="q2" value="1" ng-click="step=3">Plutôt pas d'accord {$q2at1}</label>
			<label class="col-sm-2"><input type="radio" name="q2" value="2" ng-click="step=11">Neutre {$q2at2}</label>
			<label class="col-sm-2"><input type="radio" name="q2" value="3" ng-click="step=11">Plutôt d'accord {$q2at3}</label>
			<label class="col-sm-2"><input type="radio" name="q2" value="4" ng-click="step=11">Totalement d'accord {$q2at4}</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==3">
			<div class="col-sm-12">Comment {$admin.name} pourrait-il faire de meilleurs events?</div>
			<label class="col-sm-4"><input type="radio" name="q3" value="0" ng-click="step=11">Plus les travailler {$q3at0}</label>
			<label class="col-sm-4"><input type="radio" name="q3" value="1" ng-click="step=11">Mieux les encadrer {$q3at0}</label>
			<label class="col-sm-4"><input type="radio" name="q3" value="2" ng-click="step=11">Varier les events {$q3at0}</label>
		</div>
	</div>
	
	<div class="row" ng-show="step>=10 && step < 20">
		<h3>Concernant l'administration de notre {$admin.rank} {$admin.name}</u></h3>
		<div class="form-group col-sm-12" ng-show="step==11"> 
			<div class="col-sm-12">Avez-vous déjà vu ou reçu une sanction de la part de {$admin.name}?</div>
			<label class="col-sm-4"><input type="radio" name="q11" value="1" ng-click="step=12" /> Oui, j'en ai déjà vue {$q11at1}</label>
			<label class="col-sm-4"><input type="radio" name="q11" value="2" ng-click="step=12" /> Oui, j'en ai déjà reçue {$q11at2}</label>
			<label class="col-sm-4"><input type="radio" name="q11" value="0"  ng-click="step=21"/> Non, j'en ai jamais reçue ni vue {$q11at0}</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==12">
			<div class="col-sm-12">Pensez-vous que les sanctions de {$admin.name} sont elles justes?</div>
			<label class="col-sm-2"><input type="radio" name="q12" value="0" ng-click="step=13">Pas du tout d'accord {$q12at0}</label>
			<label class="col-sm-2"><input type="radio" name="q12" value="1" ng-click="step=13">Plutôt pas d'accord {$q12at1}</label>
			<label class="col-sm-2"><input type="radio" name="q12" value="2" ng-click="step=21">Neutre {$q12at2}</label>
			<label class="col-sm-2"><input type="radio" name="q12" value="3" ng-click="step=21">Plutôt d'accord {$q12at3}</label>
			<label class="col-sm-2"><input type="radio" name="q12" value="4" ng-click="step=21">Totalement d'accord {$q12at4}</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==13">
			<div class="col-sm-12">Comment {$admin.name} pourrait-il faire des sanctions plus justes?</div>
			<label class="col-sm-4"><input type="radio" name="q13" value="0" ng-click="step=21">Réfléchir au contexte avant de sanctionner {$q13at0}</label>
			<label class="col-sm-4"><input type="radio" name="q13" value="1" ng-click="step=21">Plus de gag/mute et moins de kick/ban {$q13at1}</label>
		</div>
	</div>
	
	<div class="row" ng-show="step>=20 && step < 30">
		<h3>Concernant l'activité de notre {$admin.rank} {$admin.name}</u></h3>
		<div class="form-group col-sm-12" ng-show="step==21">
			<div class="col-sm-12">Pensez-vous que {$admin.name} règle-t-il suffisamment les problèmes du quotidien?</div>
			<label class="col-sm-2"><input type="radio" name="q21" value="0" ng-click="step=22">Pas du tout d'accord {$q21at0}</label>
			<label class="col-sm-2"><input type="radio" name="q21" value="1" ng-click="step=22">Plutôt pas d'accord {$q21at1}</label>
			<label class="col-sm-2"><input type="radio" name="q21" value="2" ng-click="step=22">Neutre {$q21at2}</label>
			<label class="col-sm-2"><input type="radio" name="q21" value="3" ng-click="step=22">Plutôt d'accord {$q21at3}</label>
			<label class="col-sm-2"><input type="radio" name="q21" value="4" ng-click="step=22">Totalement d'accord {$q21at4}</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==22">
			<div class="col-sm-12">Pensez-vous que {$admin.name} est-il suffisamment disponible?</div>
			<label class="col-sm-2"><input type="radio" name="q22" value="0" ng-click="step=23">Pas du tout d'accord {$q22at0}</label>
			<label class="col-sm-2"><input type="radio" name="q22" value="1" ng-click="step=23">Plutôt pas d'accord {$q22at1}</label>
			<label class="col-sm-2"><input type="radio" name="q22" value="2" ng-click="step=23">Neutre {$q22at2}</label>
			<label class="col-sm-2"><input type="radio" name="q22" value="3" ng-click="step=23">Plutôt d'accord {$q22at3}</label>
			<label class="col-sm-2"><input type="radio" name="q22" value="4" ng-click="step=23">Totalement d'accord {$q22at4}</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==23">
			<div class="col-sm-12">Pensez-vous que {$admin.name} s'implique-t-il suffisamment pour faire progresser le serveur?</div>
			<label class="col-sm-2"><input type="radio" name="q23" value="0" ng-click="step=24">Pas du tout d'accord {$q23at0}</label>
			<label class="col-sm-2"><input type="radio" name="q23" value="1" ng-click="step=24">Plutôt pas d'accord {$q23at1}</label>
			<label class="col-sm-2"><input type="radio" name="q23" value="2" ng-click="step=24">Neutre {$q23at2}</label>
			<label class="col-sm-2"><input type="radio" name="q23" value="3" ng-click="step=24">Plutôt d'accord {$q23at3}</label>
			<label class="col-sm-2"><input type="radio" name="q23" value="4" ng-click="step=24">Totalement d'accord {$q23at4}</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==24">
			<div class="col-sm-12">Pensez-vous que {$admin.name} fait-il du bon boulot?</div>
			<label class="col-sm-2"><input type="radio" name="q24" value="0" ng-click="step=31">Pas du tout d'accord {$q23at0}</label>
			<label class="col-sm-2"><input type="radio" name="q24" value="1" ng-click="step=31">Plutôt pas d'accord {$q24at1}</label>
			<label class="col-sm-2"><input type="radio" name="q24" value="2" ng-click="step=31">Neutre {$q24at2}</label>
			<label class="col-sm-2"><input type="radio" name="q24" value="3" ng-click="step=31">Plutôt d'accord {$q24at3}</label>
			<label class="col-sm-2"><input type="radio" name="q24" value="4" ng-click="step=31">Totalement d'accord {$q24at4}</label>
		</div>
	</div>
	
	<div class="row" ng-show="step>=30 && step < 40">
		<h3>Globalement comment évalueriez-vous notre {$admin.rank} {$admin.name}?</u></h3>
		<div class="form-group col-sm-12" ng-show="step==31">
			<div class="col-sm-12">Si vous deviez mettre une note sur 10 à {$admin.name}, combien lui donneriez vous?</div>
			<label class="col-sm-1"><input type="radio" name="q31" value="1" ng-click="step=32">1 {$q31at1}</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="2" ng-click="step=32">2 {$q31at2}</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="3" ng-click="step=32">3 {$q31at3}</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="4" ng-click="step=32">4 {$q31at4}</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="5" ng-click="step=32">5 {$q31at5}</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="6" ng-click="step=40">6 {$q31at6}</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="7" ng-click="step=40">7 {$q31at7}</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="8" ng-click="step=40">8 {$q31at8}</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="9" ng-click="step=40">9 {$q31at9}</label>
			<label class="col-sm-1"><input type="radio" name="q31" value="10" ng-click="step=40">10 {$q31at10}</label>
		</div>
		<div class="form-group col-sm-12" ng-show="step==32">
			<div class="col-sm-12">Comment {$admin.name} pourrait-il améliorer sa note?</div>
			<textarea class="form-control col-sm-offset-3" name="q32" style="width:50% !important;"></textarea>
			<a class="btn btn-success" onclick="displayQuestion(this, 'q32');">Suivant</a>
		</div>
	</div> 
	<div class="row">
		<br /><br /><br /> 
	</div>
</form>
