<div class="row">
	<div class="col-sm-8 col-md-offset-2 col-sm-offset-1">
		<h2>Erreur: {$error_num} - {$error_text.titre}</h2>
	</div>
</div>
<div class="row">
	<div class="col-sm-4 col-md-offset-1">
		<img src="/images/homer{if="$error_num>=401 && $error_num<=403"}Mad{elseif="$error_num>=500"}Serv{else}Me{/if}.png" />
	</div>
	<div class="col-sm-7">
		<h3>{$error_text.sub}</h3>
		<br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
		Vous pouvez retourner &agrave; <a href="javascript:history.go(-1);">la page pr&eacute;c&eacute;dente</a>
		{if="$debug"}
		<br/><br />
		Fichier:	{$debug.file} ligne: {$debug.line}::<br />
		{$debug.message}
		{/if}
	</div>
</div>
<br />
<script type="text/javascript">
	function goBack() {
		var backLocation = document.referrer;
		if (backLocation) {
			if (backLocation.indexOf("?") > -1) {
				backLocation += "&randomParam=" + new Date().getTime();
			} else {
				backLocation += "?randomParam=" + new Date().getTime();
			}
			window.location.assign(backLocation);
		}
	}
	{if="$back==1"}
	setTimeout(goBack, 3000);
	{/if}
</script>
