<div class="row clearfix">
	<h2 class="ThemeLettre">Parrainage:</h2>
	<div class="col-md-9 col-md-offset-1">
		<p>
			
			Le RolePlay se joue avant tout entre amis. C'est pourquoi grâce au programme de parrainage,
			vous gagnez des récompenses telles que des points pour le classement général, de l'argent
			sur le roleplay, des succès, et un titre sur le forum.
			<img src="/images/parrainage.jpg" class="img-polaroid" width="300" style="margin:15px; float:right;"/>
			<br /><br />
			<h3>&nbsp;&nbsp;&nbsp;Comment ça marche?</h3>
			<br />
			Dites à vos amis d'ajouter le roleplay à leur favoris 178.32.42.113:27015 afin de vous rejoindre.
			Ils peuvent, en cas de difficulté, cliquer sur le bouton "Rejoindre RP" présent sur notre site.<br />
			A la fin du tutoriel, le nouveau joueur pourra choisir un parrain parmi les joueurs présents sur
			le serveur. Si vous êtes connecté, il vous choisira.
			Vous pouvez aussi tenter d'aider les joueurs lorsqu'ils font le tutoriel. Les nouveaux joueurs
			ont besoin d'aide, en les aidant ils sont heureux et vous pouvez gagnez un nouveau filleul.
			<br /><br />
                        Après 20 heures d'activité, votre filleul est validé et vous pouvez bénéficier de la récompense.
			<br /><br />
			<h3>&nbsp;&nbsp;&nbsp;Récompense:</h3>
			<br />
			<ul>
				<li>À chaque filleul validé: 100 000$ RP ou 50 000XP</li>
			</ul>
			<ul>
				<li>Vous avez {$nbr1} filleul(s) en attente et {$nbr2} validé(s).
			</ul>
		</p>
	</div>
	<div class="col-md-8 col-md-offset-2">
		<table class="table table-responsive">
			{loop="list"}
				<tr>
					<th>
						{$value.name}
					</th>
					<td>
						{if="$value.approuved==1"}
							Validé, <b>Récupérer la récompense: <a href='/index.php?page=parrainage&reward={$value.steamid}&type=money'>100.000$</a> ou 
							<a href='/index.php?page=parrainage&reward={$value.steamid}&type=xp'>50.000XP</a></b>
						{elseif="$value.approuved==2"}
							Validé, 100 000$ RP reçu.
						{elseif="$value.approuved==3"}
                                                        Validé, 50 000$ XP reçu.
						{else}
							Validation en attente
						{/if}
					</td>
				</tr>
			{/loop}
		</table>
	</div>
</div>
