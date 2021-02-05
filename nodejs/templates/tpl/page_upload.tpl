<div class="row clearfix">
<h2 class="ThemeLettre">Envois de fichier:</h2>
	<br />
	<div class="col-md-8 col-md-offset-2">
	<br />
		<form name="upload" action="index.php?page=upload&type=sent" target="upload_target" method="post" id="ajax_upload" enctype="multipart/form-data" class="form-horizontal">
			<input type="hidden" name="APC_UPLOAD_PROGRESS" id="progress_key" value="{$uid}" />
			
			<div class="form-group">
				<label class="col-sm-3 control-label">Fichier à envoyer: </label>
				<div class="col-sm-6 col-md-offset-1">
					<input name="file" type="file" id="file" class="form-control" required="required" />
				</div>
			</div>
			<div class="form-group">
				<label class="col-sm-3 control-label">Type d'upload: </label>
				<div class="col-sm-6 col-md-offset-1">
					<select class="form-control" id="uploadType" onchange="toggleUploadPassword(jQuery(this).val());">
						<option value="public" default="default">Public</option>
						<option value="private">Privé</option>
					</select>
				</div>
			</div>
			<div class="form-group uploadPassword no_visible">
				<label class="col-sm-3 control-label">Mot de passe: </label>
				<div class="col-sm-6 col-md-offset-1">
					<input name="password" type="text" id="uploadPasswordInput" class="form-control" value="" />
				</div>
			</div>
			
			<div class="form-group">
				<div class="col-sm-6 col-md-offset-4 col-sm-offset-3">
					<input type="submit" id="UploadButton" class="btn btn-default" onclick="uploadFile(); jQuery('#ajax_upload').submit(); return false;" value="Envoyer" /> 
				</div>
			</div>
		</form>
		
		<div id="uploadProgress" class="hidden">
			<div class="progress" class="progress progress-striped active">
				<div class="progress-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">
				</div>
			</div>
			<div id="progress">
				<span id="progress_speed"> </span> <span id="progress_speed2"> </span> <span id="progress_time"> </span>
			</div>
		</div>
		
		<br /><br />
	</div>
<iframe id="upload_target" name="upload_target" style="width:0;height:0;border:0px solid #fff;"></iframe>
</div>