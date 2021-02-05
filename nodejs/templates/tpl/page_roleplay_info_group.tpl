<div class="alert alert-danger" role="alert"><strong>Attention</strong>, cette page va bientôt être supprimée. Merci d'utiliser <a href="/index.php?page=roleplay2#/group/{$id}"/>celle-ci</a>.</div>
<div class="row">
	<h2 class="ThemeLettre clearfix">Groupe: {$raw.job_name}</h2>
	<div class="col-sm-2 hidden-phone">
		{if="$cap.nuclearCap==$id"}
			<img src="/images/roleplay/pvp/nuke.jpg" height="200" class="img-polaroid"/>
		{/if}
	</div>
	<div class="col-sm-8">
		<img src="/images/roleplay/group/{$raw.id}.jpg" width="800" height="200" class="img-polaroid"/>
	</div>
	<div class="col-sm-2 hidden-phone">
		{if="$cap.towerCap==$id"}
			<img src="/images/roleplay/pvp/tour.jpg" height="200" class="img-polaroid"/>
		{/if}
	</div>
</div>
<div class="row">
	<div class="col-sm-8 col-sm-offset-3">
		<h2 class="ThemeLettre"> Membres: </h2>
		<table>
			{loop="row_job"}
			<tr>
				<td style="width:240px; max-width:240px; overflow:hidden; text-align:right; color:white;">
					<a href="#" onclick="
						axah('/index.php?page=roleplay&game=css&sub=job&id=1&ajax=1&steamid={$value.steamid}', jQuery('#info_job'), true, 2);
						jQuery('html, body').animate({scrollTop: jQuery('html, body').height()}, 500);
						return false;"
						style="color:white;"
					>{$value.name}</a></td>
				<td style="width:50px; text-align:center;">{$value.point}</td>
				<td style="width:150px; text-align:left; color:white;">{$value.job_name}</td>
			</tr>
			{/loop}

		</table>

	</div>
</div>

<div class="row clearfix">
	{if="$admin"}

		<h2 class="ThemeLettre"> Gestion du groupe </h2>

		<div class="col-sm-6"  >
			<h3 class="ThemeLettre"> Gestion des membres: </h3>
			<form id="edit" method="POST" class="form-horizontal">
				<input type="hidden" name="type" value="edit" />

				<div class="form-group">
					<label for="inputUser1" class="col-sm-2 control-label">Pseudo: </label>
					<div class="col-sm-6 col-md-offset-1">
						<select name="steamid" id="inputUser1" class="form-control">
							{loop="g_USERS"}
								{if="$value.is_boss == 0"}
									<option value="{$key}">{$value.name} - {$value.name}</option>
								{/if}
							{/loop}
						</select>
					</div>
				</div>
				<div class="form-group">
					<label for="inputUser2" class="col-sm-2 control-label">Grade: </label>
					<div class="col-sm-6 col-md-offset-1">
						<select name="grade" class="form-control">
							{loop="job_list"}
								{if="$value.is_boss == 0"}
									<option value='{$key}' selected='selected'>{$value.name}</option>
								{/if}
							{/loop}
							<option value='0' selected='selected'>Sans groupe</option>
						</select>
					</div>
				</div>
				<div class="form-group">
					<div id="recaptch" class="col-sm-6 col-md-offset-1"></div>

				</div>
				<div class="form-group">
					<div class="col-sm-6 col-md-offset-3">
						<input type="submit" value="Envoyer" class="btn btn-default">
					</div>
				</div>

			</form>
		</div>
		<div class="col-sm-6">
			<h3 class="ThemeLettre" > Nouveau membre: </h3>
			<form id="new" method="POST" class="form-horizontal" {if="$count|intval > 12"}data-toggle="tooltip" data-placement="top" title="{$disableReason}" {/if}>
				<input type="hidden" name="type" value="new" />

				<div class="form-group">
					<label for="inputUser1" class="col-sm-2 control-label">SteamID: </label>
					<div class="col-sm-6 col-md-offset-1">
						<input name="steamid" type="text" value="" id="EvluatingID" onchange="EvaluateSteamID();" class="form-control" {if="$count|intval > 12"}disabled{/if}/>
					</div>
				</div>
				<div class="form-group">
					<label for="inputUser2" class="col-sm-2 control-label">Grade: </label>
					<div class="col-sm-6 col-md-offset-1">
						<select name="grade" class="form-control" {if="$count|intval > 12"}disabled{/if}>
							{loop="job_list"}
								{if="$value.is_boss == 0"}
									<option value='{$key}' selected='selected' >{$value.name}</option>
								{/if}
							{/loop}
						</select>
					</div>
				</div>
				<div class="form-group">
					<div id="recaptch2" class="col-sm-6 col-md-offset-1"></div>

				</div>
				<div class="form-group">
					<label for="inputUser1" class="col-sm-2 control-label">Page Steam: </label>
					<div class="col-md-6 col-md-offset-1">
						<div class="SteamProfiler right" title="" id="EvaluatedID"></div>
					</div>
				</div>
				<div class="form-group">
					<div class="col-sm-6 col-md-offset-3">
						<input type="submit" value="Envoyer" class="btn btn-default {if="$count|intval > 12"}disabled{/if}" {if="$count|intval > 12"}disabled{/if} >
					</div>
				</div>
			</form>
		</div>

		<br clear="all" />

	<script type="text/javascript">
		var SteamID = "";
		function EvaluateSteamID() {
			var txt = jQuery("#EvluatingID").val();
			if( txt != SteamID && txt != "") {
				SteamID = txt;

				jQuery(jQuery("#EvaluatedID")).html('<div style="line-height:48px; text-align:center; color:#171717;"><img src="/images/ajax-loader.gif" /> Chargement en cours...</div>');
				    SteamProfiler_LoadData(jQuery("#EvaluatedID"), SteamID);

			}
		}
		jQuery(document).ready(function() {
			EvaluateSteamID();
			$('[data-toggle="tooltip"]').tooltip();
		});
	</script>

	{/if}
	<div id="info_job">
		<div class="col-md-8 col-md-offset-2" >
			{$capital}
		</div>
	</div>
	<div id="AxahLoadingFAT" style="position:fixed; top:50%;left:50%;"></div>
</div>
