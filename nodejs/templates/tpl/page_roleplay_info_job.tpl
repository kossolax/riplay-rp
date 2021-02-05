<div class="alert alert-danger" role="alert"><strong>Attention</strong>, cette page va bientôt être supprimée. Merci d'utiliser <a href="/index.php?page=roleplay2#/job/{$id}"/>celle-ci</a>.</div>

<div class="modal fade" id="modalShowNote" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog">
		<form action='index.php?page=roleplay&game={$game}&sub=job&id={$id}&action=editNote' method='post' class="form-horizontal">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
					<h3 class="modal-title" id="myModalLabel">Modification d'une note</h3>
				</div>
				<div class="modal-body">

					<input id="shownote_ID" name='id' type='hidden' value='-1' />

					<div class="form-group">

						<label for="shownote_TX" class="col-sm-2 control-label">Note: </label>
						<div class="col-sm-6 col-md-offset-1">
							<input id="shownote_TX" name='txt' type='text' value='-1' class="form-control" />
						</div>
					</div>
					<div class="form-group">
						<label for="inputUser15" class="col-sm-2 control-label">Cachée: </label>
						<div class="col-sm-6 col-md-offset-1">
							<input id="inputUser15" name='hidden' type='checkbox' value='0' class="form-control" />
						</div>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">Annuler</button>
					<input type="submit" class="btn btn-success" value="Sauver" />
				</div>
			</div>
		</form>
	</div>
</div>

<div class="row">
	<div class="col-md-8 col-md-offset-2">
		<h2 class="ThemeLettre clearfix">Job: {$raw.job_name}</h2>
		<img src="/images/roleplay/job/{$raw.job_id}.jpg" width="800" height="200" class="img-polaroid"/>
	</div>


	<div class="col-sm-6">
		<h4> Employés: </h4>
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
				<td style="width:25px;">{$value.admin}</td>
				<td style="width:150px; text-align:left; color:white;">{$value.job_name}</td>
				<td class="hidden-tablet">{$value.TimePlayedJob|pretty_date}</td>
			</tr>
			{/loop}

		</table>

		<h2 class="ThemeLettre"> Meilleurs Vendeurs: </h2>
		<ul style="list-style-type:decimal; margin-left:50px;">
			{loop="row_best"}
				<li>{$value.name} - {$value.point|floor}$</li>
			{/loop}
		</ul>

	</div>


	<div class="col-sm-6">
		<h4> Informations: </h4>
		<dl>
		{loop="row_log"}

			{if="$admin"}
				<dd>
					<a href='#' onclick="$('#shownote_ID').val({$value.id});$('#shownote_TX').val($(this).text());$('#modalShowNote').modal('show'); return false;"><img src="/images/icons/attack.png" />{$value.txt}</a>
				</dd>
			{else}
				{if="$value.hidden == 0"}
					<dd>{$value.txt}&nbsp;</dd>
				{/if}
			{/if}
		{/loop}
		</dl>
		<h2 class="ThemeLettre"> Hiérarchie: </h2>
		<ul>
		{loop="row_tree"}
			<li>{$value.cnt}&nbsp;&nbsp;&nbsp;{$value.job_name}: {$value.pay}$</li>
		{/loop}
		</ul>
	</div>
</div>
<div class="row clearfix">
	{if="$admin"}
		<h2 class="ThemeLettre"> Gestion du job</h2>
		<div class="col-sm-6">
			<h3 class="ThemeLettre"> Gestion des membres: </h3>
			<form id="edit" method="POST" class="form-horizontal">
				<input type="hidden" name="type" value="edit" />

				<div class="form-group">
					<label for="inputUser1" class="col-sm-2 control-label">Pseudo: </label>
					<div class="col-sm-6 col-md-offset-1">
						<select name="steamid" id="inputUser1" class="form-control">
							{loop="g_USERS"}
								{if="$value.is_boss == 0"}
									<option value="{$key}">{$value.name} - {$value.job_name}</option>
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
									<option value='{$key}' selected='selected'>{$value.job_name}</option>
								{/if}
							{/loop}
							<option value='0' selected='selected'>Sans emploi</option>
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
			<h3 class="ThemeLettre"> Nouveau membre: </h3>
			<form id="new" method="POST" class="form-horizontal">
				<input type="hidden" name="type" value="new" />

				<div class="form-group">
					<label for="inputUser1" class="col-sm-2 control-label">SteamID: </label>
					<div class="col-sm-6 col-md-offset-1">
						<input name="steamid" type="text" value="" id="EvluatingID" onchange="EvaluateSteamID();" class="form-control"/>
					</div>
				</div>
				<div class="form-group">
					<label for="inputUser2" class="col-sm-2 control-label">Grade: </label>
					<div class="col-sm-6 col-md-offset-1">
						<select name="grade" class="form-control">
							{loop="job_list"}
								{if="$value.is_boss == 0"}
									<option value='{$key}' selected='selected' >{$value.job_name}</option>
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
						<input type="submit" value="Envoyer" class="btn btn-default">
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
