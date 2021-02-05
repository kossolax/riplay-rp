<h2 class="ThemeLettre">LOG du serveur: {hostname} <span class="right"><span style="color:#{color}; font-size:26px; line-height:0px;">&bull;</span> {ip}:{port}</span></h2>
<center>
<form method="GET" action="/panel.php?page=log&serv={uniq_id}">
        <input type="hidden" name="page" value="log" />
        <input type="hidden" name="serv" value="{uniq_id}" />
	<input type="hidden" name="ajax" value="1" />

	<input type="text" name="filtre" value="{filtre}" size="100" class="inputbox">
	<input type="submit" value="Filtrer" class="button2">
</form>
</center>
<hr />
<div id="LogData" style="font-size:12px;">
	{log}

</div>
<br />
