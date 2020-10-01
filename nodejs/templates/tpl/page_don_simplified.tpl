<div class="row clearfix">
	<h2 class="ThemeLettre">Achat de $RP:</h2>
	<div class="col-md-8 col-md-offset-2">
		<p class="ThemeLettre">
			Vous souhaitez aider financi&egrave;rement le serveur?
			Vous le pouvez, et c'est tout &agrave; votre avantage!<br />
			Les donateurs sont un réel soutien pour le serveur,
			ainsi nous vous offrons une somme d'argent sur le Roleplay CS:GO
			proportionnelle aux dons que vous nous faites.
			<br /><br />
			Votre soutien compte beaucoup pour nous, c'est pourquoi, chaque donateur reçoit un grade
			sur le forum dans l'objectif d'être dicerné des autres.	Ainsi nous pouvons mieux
			être à votre écoute pendant 1 mois après votre don.
			Les meilleurs donateurs sont aussi récompensés par un skin unique sur notre serveur pour
			les mêmes raisons: C'est une façon d'inter-agir avec un
			    niveau d’écoute plus élevé qu'avec les autres joueurs.

			<br /><br />

			Coût de nos serveurs: 220&euro;.
                        Pourquoi nos serveurs coûtent si cher? Nous souhaitons une qualité de jeu irréprochable. C'est pourquoi nous avons du matériel haute gamme et des serveurs très puissant.
                        Nous mettons aussi l'accent sur l'impossibilité de nous DDoS. Mais cela a un prix...

		</p>
	</div>
	<div class="col-md-5 col-md-offset-1">
		<h3>StarPass:</h3>
		<p class="text-center">1 Code = 15 000$RP.</p>
		<div id="starpass_256922"></div>
	</div>
</div>
<script type="text/javascript">
	$(window).load( function() {
		$.getScript( "https://script.starpass.fr/script.php?idd=256922&verif_en_php=1&datas=&theme=dark_grey_small&last=1" );
	});
</script>
<div class="row clearfix">
	<h2>Les 10 meilleurs donateurs ce mois:</h2>
	<div class="col-md-8 col-md-offset-2">
		<div class="col-sm-7">
			<p>Être dans ce classement, vous honore. C'est pourquoi nous vous offrons un skin unique sur le serveur tant que vous êtes dans ce classement.
			De plus, à la fin du mois. vous recevrez une voiture unique sur le serveur. L'entrée du classement ce-mois ci est à {$inTop10}€, ou {$inTop10RP|pretty_number}$RP reçu. </p>
			<ol>
				{loop="$top10"}
					{if="$key<=10"}
						<li>{$value.uname2}</li>
					{/if}
				{/loop}
			</op>
		</div>
		<div class="col-sm-3">
			<a class="various" href="/images/donateurgift.jpg">
				<img src="/images/donateurgift.jpg" class="img-polaroid" class="pull-right" />
			</a>
		</div>
		
	</div>
</div>
<br />

