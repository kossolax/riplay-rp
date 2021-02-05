<div class="row clearfix">
	<h2 class="ThemeLettre">Téléchargement de fichier:</h2>
	<div class="table-responsive">
		<table class="table table-condensed table-hover">
			<thead>
				<tr>
					<th></th>
					<th></th>
					<th>Fichier:</th>
					<th class="hidden-phone">Téléchargement:</th>
					<th class="hidden-phone">Envoyé par:</th>
					<th class="hidden-phone hidden-tablet">Date d'ajout:</th>				
				</tr>
			</thead>
			<tbody>
				{loop="$row"}
					<tr>
						<td>
							{if="$value.user_id==$userID || $userID == 2 "}
								<a href="/index.php?page=download&action=remove&id={$value.id}"><img src="images/icons/delete.gif" width="10" height="10" />
							{/if}
						</td>
						<td>
							{if="$value.is_prive==1"}
								<img src="/images/icons/lock.gif" width="10" height="10" />
							{/if}
							{if="$value.ext=='mp3'"}
								<img src="images/icons/audio.gif" width="10" height="10" />
							{/if}
							{if="$value.pic==1"}
								<img src="images/icons/image.gif" width="10" height="10" />
							{/if}
						</td>
						<td>
							{if="$value.ext=='mp3' && $value.is_prive==0"}
								<a href="/swf/mp3_player.swf?firstColor=ffffff&secondColor=2288ee&backColor=000000&strokeColor=000000&autoLoad=1&mediaPath=/download/{$value.id}/{$value.nom_fichier}" 
									class="various iframe">{$value.nom_fichier}</a>
							{else}
								<a href="download/{$value.id}/{$value.nom_fichier}" 
									{if="$value.is_prive==1"}
										onclick="AskPassword({$value.id}, '{$value.nom_fichier}'); return false;"
									{/if}
									{if="$value.pic==1"}
										class="various"
									{/if}
								>{$value.nom_fichier}</a>
							{/if}
						</td>
						<td class="hidden-phone">{$value.downloaded}</td>
						<td class="hidden-phone">{$value.username}</td>
						<td class="hidden-phone hidden-tablet">{$value.timestamp|prettytime}</td>
					</tr>
				{/loop}
				
			</tbody>
		</table>
	</div>
</div>