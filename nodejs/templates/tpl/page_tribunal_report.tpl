<h2> Le tribunal: Rapporter un joueur</h2>
<div class="col-md-12">
	<div class="row clearfix">
		<p>
			Certain joueur ont malheureusement une attitude négative sur le serveur et ne respectent pas le <a href="/forum/viewtopic.php?p=416771#p416771">règlement</a>.
			Si vous avez des problèmes avec un joueur, et qu'un policier ou qu'un juge n'a rien pu faire, il est toujours possible de faire quelque chose.
			Entrez le steamID de la personne, et donner la raison de pourquoi vous souhaiter la condamner. Le conseil des no-pyj votera, et un juge sanctionnera le joueur même si celui-ci est déconnecté!
		</p>
		<hr />
		<form action="index.php?page=tribunal&action=post"  method="POST" id="report_send" class="form-horizontal">
			<div class="form-group">
				<label for="EvluatingID" class="col-sm-2 control-label">SteamID: </label>
				<div class="col-sm-6 col-md-offset-1">
					<input type="text" name="report_steamid" placeholder="STEAM_1:x:zzzzzzz" class="form-control" id="EvluatingID" onchange="EvaluateSteamID();" required="required" value="{$steamid}" />
				</div>
			</div>
			<div class="form-group">
				<label for="EvluatingID" class="col-sm-2 control-label">Date / Heure IRL: </label>
				<div class="col-sm-6 col-md-offset-1">
					<input type="text" name="timestamp" class="form-control" required="required" value="{$timestamp}" />
				</div>
			</div>
			<div class="form-group">
				<label for="EvluatingID" class="col-sm-2 control-label">Raison: </label>
				<div class="col-sm-6 col-md-offset-1">
					<select name="reason" id="select" class="form-control" required="required">
						<option default="default"></option>
                                    <option>Insultes, Irrespect</option>
                                    <option>Kill massif</option>
                                    <option>Abus de ses fonctions</option>
                                    <option>Exploit, Triche</option>
                                    <option>Attitude négative</option>
                                    <option>Menaces, Hack</option>
						<option>Autre (Préciser):</option>
					</select>
				</div>
			</div>
			<div class="form-group">
				<label for="EvluatingID" class="col-sm-2 control-label">Informations: </label>
				<div class="col-sm-6 col-md-offset-1">
					<textarea name="moreinfo" class="form-control" required="required" ></textarea>
				</div>
			</div>
			<div class="form-group">
				<label for="EvluatingID" class="col-sm-2 control-label">Steam: </label>
				<div class="col-sm-4 col-md-offset-1">
					<div class="SteamProfiler right" title="{$steamid}" id="EvaluatedID"></div>
				</div>
				<div class="col-sm-5">
					<input type="submit" value="Rapporter" class="btn btn-warning" /> <a class="btn btn-success" href="/index.php?page=tribunal&action=rules">S'occuper du tribunal</a>
				</div>
			</div>
		</form>
	</div>
</div>
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
