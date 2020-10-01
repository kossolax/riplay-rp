<div class="block-800">
<h2 class="ThemeLettre">Sondage: Le RolePlay</h2>

<script type="text/javascript">
	var position = new Array();
	function displayQuestion(that, id1, id2) {
		if( $(that).val() == "Suivant" ) {
			if( position[id1] === undefined )
				position[id1] = 0;
			
			
			
			$.ajax({
				type: "GET",
				url: "/index.php?page=sondage&action=ind&q="+id1+"&v="+position[id1],
				cache: true,
				success: function(res) {
					$(that).parent().find("textarea").val( res );
					position[id1]++;
				}
			});
		}
	}
</script>
<style type="text/css">
	#sondage_form>div {
		margin-top:10px;
		padding-bottom: 10px;
		border-bottom:2px dotted black;
	}
	#progress {
		text-align:center;
	}
</style>

<form action="index.php?page=sondage&action=post" method="post" id="sondage_form">
	
	<div id="progress"> Nombre de votant: {total} </div>
	
	<div id="q_1">
		<blockquote>
			1. Sur une échelle de 1 à 5, Combien donneriez vous à l'ambiance générale qui règle sur le serveur RolePlay?
		</blockquote>
		<br />
		<div class="block-600 center">
			<label>
				<input type="radio" name="q_1" value="1" onclick="displayQuestion(this, 'q_1', 'q_1_1');" /> 1 {q_1at1}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_1" value="2" onclick="displayQuestion(this, 'q_1', 'q_1_1');" /> 2 {q_1at2}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_1" value="3" onclick="displayQuestion(this, 'q_1', 'q_1_1');" /> 3 {q_1at3}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_1" value="4" onclick="displayQuestion(this, 'q_1', 'q_1_1');" /> 4 {q_1at4}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_1" value="5" onclick="displayQuestion(this, 'q_1', 'q_2');" /> 5 {q_1at5}
			</label>
		</div>
	</div>
	<div id="q_1_1">
		<blockquote>
			1.a. Quels sont les problèmes qui vous agacent lorsque vous jouez sur le serveur?
				(Même les problèmes qui vous paraissent insignifiant sont importants pour nous).
		</blockquote>
		<br />
		<div class="block-600 center">
			<textarea name="q_1_1" style="width:400px; height:100px;"></textarea>
			<input type="button" onclick="displayQuestion(this, 'q_1_1', 'q_1_2');" value="Suivant" />
		</div>
	</div>
	<div id="q_1_2">
		<blockquote>
			1.b. Quels sont les soucis ou les situations que vous rencontrez et qui nuisent à votre
				épanouissement sur le serveur et qui vous paraissent injustes ou mal réprimandés
				par le code pénal ou le règlement général du serveur ?
				(ex : Lorsque un policer jette son arme lorsqu’il est volé par un 18th, etc)
				(Même les problèmes qui vous paraissent insignifiant sont importants pour nous).
		</blockquote>
		<br />
		<div class="block-600 center">
			<textarea name="q_1_2" style="width:400px; height:100px;"></textarea>
			<input type="button" onclick="displayQuestion(this, 'q_1_2', 'q_2');" value="Suivant" />
		</div>
	</div>
	
	
	
	<div id="q_2">
		<blockquote>
			2. Sur une échelle de 1 à 5, Combien donneriez-vous aux forces de l'ordre du serveur?
		</blockquote>
		<br />
		<div class="block-600">
			<label>
				<input type="radio" name="q_2" value="1" onclick="displayQuestion(this, 'q_2', 'q_2_1');" /> 1 {q_2at1}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_2" value="2" onclick="displayQuestion(this, 'q_2', 'q_2_1');" /> 2 {q_2at2}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_2" value="3" onclick="displayQuestion(this, 'q_2', 'q_2_1');" /> 3 {q_2at3}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_2" value="4" onclick="displayQuestion(this, 'q_2', 'q_2_1');" /> 4 {q_2at4}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_2" value="5" onclick="displayQuestion(this, 'q_2', 'q_3');" /> 5 {q_2at5}
			</label>
		</div>
	</div>
	<div id="q_2_1">
		<blockquote>
			2.a. Trouvez vous que les policiers sont trop strictes ou pas assez ? Précisez
				(Même les problèmes qui vous paraissent insignifiant sont importants pour nous).
		</blockquote>
		<br />
		<div class="block-600 center">
			<textarea name="q_2_1" style="width:400px; height:100px;"></textarea>
			<input type="button" onclick="displayQuestion(this, 'q_2_1', 'q_2_2');" value="Suivant" />
		</div>
	</div>
	<div id="q_2_2">
		<blockquote>
			2.b. Pensez vous que le réglement des forces de l’ordre n’est pas assez précis dans
				certaines situations ? Si oui lesquelle(s)
				(Même les problèmes qui vous paraissent insignifiant sont importants pour nous).
		</blockquote>
		<br />
		<div class="block-600 center">
			<textarea name="q_2_2" style="width:400px; height:100px;"></textarea>
			<input type="button" onclick="displayQuestion(this, 'q_2_2', 'q_3');" value="Suivant" />
		</div>
	</div>
	
	
	
	<div id="q_3">
		<blockquote>
			3. Sur une échelle de 1 à 5, Combien donneriez-vous au tribunal <strong>IN-GAME</strong>?
		</blockquote>
		<br />
		<div class="block-600">
			<label>
				<input type="radio" name="q_3" value="1" onclick="displayQuestion(this, 'q_3', 'q_3_1');" /> 1 {q_3at1}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_3" value="2" onclick="displayQuestion(this, 'q_3', 'q_3_1');" /> 2 {q_3at2}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_3" value="3" onclick="displayQuestion(this, 'q_3', 'q_3_1');" /> 3 {q_3at3}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_3" value="4" onclick="displayQuestion(this, 'q_3', 'q_3_1');" /> 4 {q_3at4}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_3" value="5" onclick="displayQuestion(this, 'q_3', 'q_4');" /> 5 {q_3at5}
			</label>
		</div>
	</div>
	<div id="q_3_1">
		<blockquote>
			3.a. Pensez vous que le tribunal In-Game est pleinement utilisé? Quels atouts voudriez-vous
				ajouter pour améliorer les institutions légales
				(Même les problèmes qui vous paraissent insignifiant sont importants pour nous).
		</blockquote>
		<br />
		<div class="block-600 center">
			<textarea name="q_3_1" style="width:400px; height:100px;"></textarea>
			<input type="button" onclick="displayQuestion(this, 'q_3_1', 'q_4');" value="Suivant" />
		</div>
	</div>
	
	
	<div id="q_4">
		<blockquote>
			4. Sur une échelle de 1 à 5, Combien donneriez-vous au tribunal <strong>FORUM</strong>?
		</blockquote>
		<br />
		<div class="block-600">
			<label>
				<input type="radio" name="q_4" value="1" onclick="displayQuestion(this, 'q_4', 'q_4_1');" /> 1 {q_4at1}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_4" value="2" onclick="displayQuestion(this, 'q_4', 'q_4_1');" /> 2 {q_4at2}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_4" value="3" onclick="displayQuestion(this, 'q_4', 'q_4_1');" /> 3 {q_4at3}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_4" value="4" onclick="displayQuestion(this, 'q_4', 'q_4_1');" /> 4 {q_4at4}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_4" value="5" onclick="displayQuestion(this, 'q_4', 'q_5');" /> 5 {q_4at5}
			</label>
		</div>
	</div>
	<div id="q_4_1">
		<blockquote>
			4.a. Que pensez-vous de l’utilisation actuelle du tribunal forum? 
				Avez-vous des idées pour l’améliorer ? si oui lesquelle(s)
				(Même les problèmes qui vous paraissent insignifiant sont importants pour nous).
		</blockquote>
		<br />
		<div class="block-600 center">
			<textarea name="q_4_1" style="width:400px; height:100px;"></textarea>
			<input type="button" onclick="displayQuestion(this, 'q_4_1', 'q_5');" value="Suivant" />
		</div>
	</div>
	
	
	
	
	<div id="q_5">
		<blockquote>
			5. Sur une échelle de 1 à 5, Combien donneriez-vous aux concept de guerre des gangs?
		</blockquote>
		<br />
		<div class="block-600">
			<label>
				<input type="radio" name="q_5" value="1" onclick="displayQuestion(this, 'q_5', 'q_5_1');" /> 1 {q_5at1}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_5" value="2" onclick="displayQuestion(this, 'q_5', 'q_5_1');" /> 2 {q_5at2}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_5" value="3" onclick="displayQuestion(this, 'q_5', 'q_5_1');" /> 3 {q_5at3}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_5" value="4" onclick="displayQuestion(this, 'q_5', 'q_5_1');" /> 4 {q_5at4}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_5" value="5" onclick="displayQuestion(this, 'q_5', 'q_6');" /> 5 {q_5at5}
			</label>
		</div>
	</div>
	<div id="q_5_1">
		<blockquote>
			5.a. Sur une échelle de 1 à 5, que pensez vous de l’idée suivante?
			<br /><br />
		<pre>
		Le PvP pose toujours problème. Peut de gens vont dans les zones, certain
	gang ne veulent pas jouer à ça. Il y a aussi trop de critère, et le système de
	point est trop compliqué.

		Faisons autrement. Sur CSGO, quand le moment serra venu, on refondera
	4 ou 5 gang. Le prix de la création d'un gang serra de l'argent réel, et serra
	redistribué sous forme d'event/cadeau steam. afin de limiter la création de
	groupe. Mais là n'est pas l'idée principale, ceci est juste pour limiter les gang
	et de ne plus se retrouver à 15.

		Passons donc au point important, le PvP.
	Que pensez-vous de fixer un PvP global (de PvP à non PvP) à heure fixe?
	Imaginez des joueurs s'entre-tuer pour leur gang de 20h à 21h IRL tout les
	soirs? Au lieu de faire ça permanence dans une zone limitée. Les gens seront
	donc prêt à l'heure et penserons à ce stuff en soirée.

	Imaginez maintenant non pas 1 base immense, mais 3 petites bases & lieu
	stratégique dans la ville à capturer le mercredi soir, vendredi soir, et dimanche
	soir? Un peu comme aion, ou des forteresses dans les MMO. Chacun de ces
	points stratégiques donneront des avantages différents. On peut parler de
	bonus dans un job (item gratuit?), d'argent, de zone de respawn, temps
	de jail réduit, arme pour PvP gratuite, etc, etc.

	Chacune des bases rapportent à leur gang 2500 points, et le système d'ELO
	par joueur. Pas d'autre critère. Une place chef dans un gang est déjà un
	avantage, pas besoin de rajouter des points. Le flood forum est tout aussi
	ridicule.
		</pre>
		</blockquote>
		<br />
		<div class="block-600">
			<label>
				<input type="radio" name="q_5_1" value="1" onclick="displayQuestion(this, 'q_5_1', 'q_5_2');" /> 1 {q_5_1at1}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_5_1" value="2" onclick="displayQuestion(this, 'q_5_1', 'q_5_2');" /> 2 {q_5_1at2}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_5_1" value="3" onclick="displayQuestion(this, 'q_5_1', 'q_5_2');" /> 3 {q_5_1at3}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_5_1" value="4" onclick="displayQuestion(this, 'q_5_1', 'q_5_2');" /> 4 {q_5_1at4}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_5_1" value="5" onclick="displayQuestion(this, 'q_5_1', 'q_6');" /> 5 {q_5_1at5}
			</label>
		</div>
	</div>
	<div id="q_5_2">
		<blockquote>
			5.b. Avez-vous des modifications ou des précisions à apporter ? Si oui lesquelle(s)
				(Même les problèmes qui vous paraissent insignifiant sont importants pour nous).
		</blockquote>
		<br />
		<div class="block-600 center">
			<textarea name="q_5_2" style="width:400px; height:100px;"></textarea>
			<input type="button" onclick="displayQuestion(this, 'q_5_2', 'q_6');" value="Suivant" />
		</div>
	</div>
	
	<div id="q_6">
		<blockquote>
			6. Sur une échelle de 1 à 5, Combien donneriez-vous à la qualité des admins? Sont-ils disponiblent?
			Sont-ils assez présent?
		</blockquote>
		<br />
		<div class="block-600">
			<label>
				<input type="radio" name="q_6" value="1" onclick="displayQuestion(this, 'q_6', 'q_6_1');" /> 1 {q_6at1}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_6" value="2" onclick="displayQuestion(this, 'q_6', 'q_6_1');" /> 2 {q_6at2}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_6" value="3" onclick="displayQuestion(this, 'q_6', 'q_6_1');" /> 3 {q_6at3}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_6" value="4" onclick="displayQuestion(this, 'q_6', 'q_6_1');" /> 4 {q_6at4}
			</label>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<label>
				<input type="radio" name="q_6" value="5" onclick="displayQuestion(this, 'q_6', 'q_7');" /> 5 {q_6at5}
			</label>
		</div>
	</div>
	<div id="q_6_1">
		<blockquote>
			6.a. Rencontrez vous des problèmes avec les admins ? Si oui lesquels. (C'est anonyme, lachez vous.)
				(Même les problèmes qui vous paraissent insignifiant sont importants pour nous).
		</blockquote>
		<br />
		<div class="block-600 center">
			<textarea name="q_6_1" style="width:400px; height:100px;"></textarea>
			<input type="button" onclick="displayQuestion(this, 'q_6_1', 'q_7');" value="Suivant" />
		</div>
	</div>
	
	<div id="q_7">
		C'est la fin, merci d'avoir répondu à notre sondage!<br />
		Les données vont être enregistrée, analysée et publiée afin de voir l'avis général des joueurs.<br />
		Des actions serront prises en conséquence afin d'améliorer nos services. <br /><br /><br />
		
		<center>
			<input type="submit" value="Envoyer" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="button" onclick="displayQuestion(this, 'q_7', 'q_1');" value="Recommencer" />
		</center>
	</div>
</form>

</div>
<br />
