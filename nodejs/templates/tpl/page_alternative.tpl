<form class="col-md-12 form-horizontal" method="get" action="/index.php">
<input type="hidden" name="page" value="test" />
<fieldset>

<h2>Changer le logo du site</h2>

<div class="form-group">
	<label class="col-md-3 control-label" for="URL">URL</label>  
	<div class="input-group col-md-9">
		<input type="url" class="form-control" name="alt" type="text" placeholder="http://...." required="" value="{$alt}" />
		<span class="input-group-btn">
			<input type="submit" class="btn btn-search" value="Remplacer" />
		</span>
	</div>
</div>

</fieldset>
</form>

