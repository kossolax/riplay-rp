<h2 class="ThemeLettre">Gestion du serveur: {hostname} <span class="right"><span style="color:#{color}; font-size:26px; line-height:0px;">&bull;</span> {ip}:{port}</span></h2>

<script>
function SendCommand(cmd) {
	jQuery.ajax({
		type: "GET",
		url: "/panel.php?page=shell_serv&serv={uniq_id}&action="+cmd+"&ip={ip}",
		cache: false,
		success: function(result) {
			var data = result.split(":");
			MakingAlert(data[0], data[1]);
		}
	});
}
function Confirm(cmd) {
	msg = "Attention, vous-&ecirc;tes sur le point d'effectuer la commande: <strong>"+cmd+"</strong><br />";
	msg = msg + "Confirmez-vous celle-ci? <a href='#' onclick='SendCommand(\""+cmd+"\"); DeleteAlert(); return false;'>Oui</a> - <a href='#' onclick='DeleteAlert(); return false;'>Non</a>";
	MakingAlert("Attention", msg); 
}
</script>

<table class="center" style="width:99%;">
	<tr>
		<td style="width:180px;">
			<div class="inputButton" style="width:100px; text-align:center;" onclick="SendCommand('start'); return false;"> Démarrer </div>
			<div class="inputButton" style="width:100px; text-align:center;" onclick="SendCommand('stop'); return false;"> Arrêter </div>
			<div class="inputButton" style="width:100px; text-align:center;" onclick="SendCommand('reboot'); return false;"> Redémarrer </div>
			<div class="inputButton" style="width:100px; text-align:center;" onclick="Confirm('update'); return false;"> Mise à jour </div>
                        <div class="inputButton" style="width:100px; text-align:center;" onclick="SendCommand('url'); return false;"> UpdateURL </div>
			<div class="inputButton" style="width:100px; text-align:center;" onclick="location.href='/panel.php?page=log&serv={uniq_id}'; return false;"> Log </div>
			<div class="inputButton" style="width:100px; text-align:center;" onclick="location.href='/cache/{uniq_id}.html'; return false;"> Stats </div>
                        <div class="inputButton" style="width:100px; text-align:center;" onclick="location.href='/cache/doubleCompte.txt'; return false;"> Double Compte </div>

			<div style="text-align:center; width:140px;">Log Admin:</div>
			<div style="height:405px; border: 1px solid #ffffff; line-height:7px; overflow:auto; font-size:6px;">{log}</div>
		</td>
		<td style="width:auto;">
			<iframe src="https://www.ts-x.eu/node/?ip={ip}&port={port}" style="border:0px #FFFFFF none;" name="myiFrame" scrolling="no" frameborder="0" marginheight="0px" marginwidth="0px" height="100%" width="100%"></iframe>
		</td>
	</tr>
</table>
<br />

