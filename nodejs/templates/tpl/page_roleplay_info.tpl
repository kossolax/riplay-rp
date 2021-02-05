<style>
.strikethrough {
  position: relative;
}
.strikethrough:before {
  position: absolute;
  content: "";
  left: 0;
  top: 50%;
  right: 0;
  border-top: 12px solid red;
  border-radius:12px;

  -webkit-transform:rotate(-40deg);
  -moz-transform:rotate(-40deg);
  -ms-transform:rotate(-40deg);
  -o-transform:rotate(-40deg);
  transform:rotate(-40deg);
}

</style>

<div class="alert alert-danger" role="alert"><strong>Attention</strong>, cette page va bientôt être supprimée. Merci d'utiliser <a href="/index.php?page=roleplay2"/>celle-ci</a>.</div>

<div class="row clearfix">
	<div class="col-sm-6">
		<div class="row">
			<h2 class="ThemeLettre"> Liste des Jobs: </h2>
			<ul style="text-align:left; padding-left:50px;">
				{loop="job_list"}
					<li><a href='/index.php?page=roleplay&game={$game}&sub=job&id={$value.job_id}' style='{$value.warn_chef}'>{$value.job_name}</a>
						<span style='{$value.warn_quota}'>[{$value.current}/{$value.quota}]</span> </li>
				{/loop}
			</ul>
		</div>
	</div>
	<div class="col-sm-6">
{if="$cap.capItem>0"}<span class="strikethrough" style="display:block; float:right;">Désactivé pour la capture:<br /><img src="https://www.ts-x.eu/images/roleplay/csgo/items/{$cap.capItem}.png" width="120" /></span>{/if}
		<div class="row">
			<h2 class="ThemeLettre"> Liste des Groupes: </h2>
				<table>
					{loop="group_list"}
						<tr>
							<td style="text-align:right;">
								<a href='/index.php?page=roleplay&game={$game}&sub=group&id={$value.id}' style='color: rgb({$value.color}); text-shadow:0px 0px 10px rgb({$value.color});'>
									{$value.job_name}
								</a>
							</td>
							<td width="50"></td>
							<td>
								{$value.stats2}
							</td>
						</tr>
					{/loop}
				</table>
				<br />

				{if="$myself.group_id > 0"}
					<h2 class="ThemeLettre"> Quitter son groupe: </h2>
					<form id="leave" method="POST" action="index.php?page=roleplay&game={$game}&type=group&action=leave">
						<input type="submit" name="quit" value="Quitter" class="btn btn-default">
					</form>

				{/if}
			<br />
			<h2 class="ThemeLettre"> Recherche de SteamID: </h2>
			<form id="new" method="POST">
				<div class="form-inline">
					<div class="input-group">
						<input type="text" name="search" value="" placeholder="Pseudo" class="form-control" />
						<span class="input-group-btn">
							<input type="submit" value="Rechercher" class="btn btn-default">
						</span>
					</div>
				</div>
			</form>
		</div>
	</div>
</div>
<div class="row clearfix">
	<div class="col-md-8 col-md-offset-2" >
		<div class="row">
			<h2 class="ThemeLettre"> Votre résumé: </h2>
			{if="$myself.job_id > 0"}
				<img class="img-polaroid" src='/do/signature/job/{$myself.steamid}.jpg' />
			{/if}
			{if="$myself.group_id > 0"}
				<img class="img-polaroid" src='/do/signature/group/{$myself.steamid}.jpg' />
			{/if}
		</div>
	</div>
</div>
