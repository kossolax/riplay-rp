<div class="row clearfix">
<h2 class="ThemeLettre">Achat de $RP:</h2>
	{if="$lastMonth"}
	{/if}
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

		        Coût de nos serveurs: 220&euro;. {if="$objectif>220"} C'est payé, merci !{else}<img src="//www.ts-x.eu/images/grad.php?per={$objectif/220*100}&text={$objectif|floor} / 220&hex=00498c" />{/if}<br />
			Pourquoi nos serveurs coûtent si cher? Nous souhaitons une qualité de jeu irréprochable. C'est pourquoi nous avons du matériel haute gamme et des serveurs très puissant.
			Nous mettons aussi l'accent sur l'impossibilité de nous DDoS. Mais cela a un prix...
			<br /><br />
		</p>
	</div>
	<div class="col-md-4 col-md-offset-1">
		<div class="row">
			<h3>PaySafeCard:</h3>
			<p>
				Traitement dans les 5 minutes en journée (12 heures maximum).
				Les PaySafeCard JUNIOR ne sont pas acceptées. Uniquement France/Belgique.
				<img src="/images/paysafecard.png" width="200" class="pull-right"/>
			</p>
			<br clear="all" />
			<form action="index.php?page=money&paysafecard=1" method="POST">
				<div class="form-group">
					<label class="col-sm-3 control-label" for="textinput">Code:</label>
					<div class="col-sm-7">
						<input name="code" placeholder="xxxx-xxxx-xxxx-xxxx" class="form-control input-sm" required="required" />
					</div>
				</div>
				<div class="form-group">
					<label class="col-sm-3 control-label">Montant:</label>
					<div class="col-sm-7">
						<select name="amount" class="form-control">
							<option value="1">9 400$RP pour €1,00 EUR</option>
							<option value="5">47 000$RP pour €5,00 EUR</option>
							<option value="10" selected="selected">94 000$RP pour €10,00 EUR</option>
							<option value="20">188 000$RP pour €20,00 EUR</option>
							<option value="25">235 000$RP pour €25,00 EUR</option>
							<option value="50">470 000$RP pour €50,00 EUR</option>
							<option value="42">Ce qui me reste sur la carte</option>
							
						</select>
					</div>
				</div>
				
				<div class="col-sm-7 col-sm-offset-3">
					<input type="submit" class="btn btn-default" value="Envoyer" />
				</div>
			</form>
		</div>
		<div class="row">
			<h3>PayPall:</h3>
			<p>
				La validation s'effectue automatiquement à la fin de votre paiement.
				Cependant, des vérifications sur votre identité peuvent vous-être demandée afin de vérifier que vous êtes bien
				le propriétaire de votre compte PayPal.
				<img src="/images/paypal.png" width="200" class="pull-right" />
			</p>
			<br clear="all" />
			<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
				<input type="hidden" name="cmd" value="_s-xclick">
				<input type="hidden" name="hosted_button_id" value="MQ6WUF4PZEWJQ">
				<input type="hidden" name="on0" value="Achat de $RP">
				<div class="form-group">
					<label class="col-sm-3 control-label">Montant:</label>
					<div class="col-sm-7">
						<select name="os0" class="form-control">
							<option value="6 200$RP pour">6 200$RP pour €1,00 EUR</option>
							<option value="15 800$RP pour">15 800$RP pour €2,00 EUR</option>
							<option value="44 800$RP pour">44 800$RP pour €5,00 EUR</option>
							<option value="93 100$RP pour" selected="selected">93 100$RP pour €10,00 EUR</option>
							<option value="189 700$RP pour">189 700$RP pour €20,00 EUR</option>
							<option value="479 500$RP pour">479 500$RP pour €50,00 EUR</option>
						</select>
					</div>
				</div>
				<input type="hidden" name="on1" value="SteamID">
				<input type="hidden" name="os1" maxlength="200" value="{$steamid}">
				<input type="hidden" name="currency_code" value="EUR">
				<div class="col-sm-7 col-sm-offset-3">
					<input type="submit" class="btn btn-default" value="Envoyer" />
				</div>
			</form>
		</div>
	</div>
	<div class="col-md-5">
		<h3>StarPass:</h3>
		<p class="text-center">1 Code = 15 000$RP.</p>
		<div id="starpass_14466"></div>
	</div>
</div>
<script type="text/javascript">
	$(window).load( function() {
		$.getScript( "https://script.starpass.fr/script.php?idd=14466&verif_en_php=1&datas=&theme=dark_grey_small&last=1" );
	});
</script>

<div class="row clearfix">
<hr />
<br /><br /><br />
<div id="carousel-example-generic" class="carousel slide" data-ride="carousel">
  <ol class="carousel-indicators">
    <li data-target="#carousel-example-generic" data-slide-to="0" class="active"></li>
    <li data-target="#carousel-example-generic" data-slide-to="1"></li>
    <li data-target="#carousel-example-generic" data-slide-to="2"></li>
  </ol>
  <div class="carousel-inner" role="listbox">
    <div class="item active">
	<h2>Besoin d'argent?</h2>
	<p>Transformez vos tokkens en argent.</p>

	<div class="row">
		<div class="col-sm-2">
			<div class="thumbnail tb2">
				<div class="caption">
					<h3><i>9 Tokken</i><br /><strong>10 000$RP</strong></h3>
				</div>
				<img src="/images/roleplay/csgo/items/22.png" width="60" height="60">
			</div>
		</div>
                <div class="col-sm-2">
                        <div class="thumbnail tb2">
                                <div class="caption">
                                        <h3><i>47 Tokkens</i><br /><strong>50 000$RP</strong></h3>
                                </div>
                                <img src="/images/roleplay/csgo/items/22.png" width="60" height="60">
                        </div>
                </div>
                <div class="col-sm-2">
                        <div class="thumbnail tb2">
                                <div class="caption">
                                        <h3><i>97 Tokkens</i><br /><strong>100 00$RP</strong></h3>
                                </div>
                                <img src="/images/roleplay/csgo/items/22.png" width="60" height="60">
                        </div>
                </div>
                <div class="col-sm-2">
                        <div class="thumbnail tb2">
                                <div class="caption">
                                        <h3><i>188 Tokkens</i><br /><strong>200 000$RP</strong></h3>
                                </div>
                                <img src="/images/roleplay/csgo/items/22.png" width="60" height="60">
                        </div>
                </div>
                <div class="col-sm-2">
                        <div class="thumbnail tb2">
                                <div class="caption">
                                        <h3><i>235 Tokkens</i><br /><strong>250 000$RP</strong></h3>
                                </div>
                                <img src="/images/roleplay/csgo/items/22.png" width="60" height="60">
                        </div>
                </div>
                <div class="col-sm-2">
                        <div class="thumbnail tb2">
                                <div class="caption">
                                        <h3><i>470 Tokkens</i><br /><strong>500 000$RP</strong></h3>
                                </div>
                                <img src="/images/roleplay/csgo/items/22.png" width="60" height="60">
                        </div>
                </div>

	</div>
    </div>
    <div class="item">
    </div>
  </div>
  <a class="left" href="#carousel-example-generic" role="button" data-slide="prev">
    <span aria-hidden="true">&leftarrow;</span>
  </a>
  <a class="pull-right" href="#carousel-example-generic" role="button" data-slide="next">
    <span aria-hidden="true">&rightarrow;</span>
  </a>
</div>
</div>
<br />
