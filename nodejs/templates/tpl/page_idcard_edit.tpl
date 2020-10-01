<script type="text/javascript">
	function ValidationID() {
		var nom = jQuery("#inputNom").val();
		var prenom = jQuery("#inputPrenom").val();

		var text = 'Attention, définir votre nom est permanent. ';
		text = text + 'Une fois défini, il est impossible de le modifier. <br />';
		text = text + '&Ecirc;tes vous sur de vouloir vous appeller: <br />';
		text = text + '&nbsp;&nbsp;&nbsp; '+ nom +' '+ prenom +'.<hr />';
		text = text + '<div class="left"><a href="/index.php?page=idcard&nom='+nom+'&prenom='+prenom+'">Oui</a></div>';
		text = text + '<div class="right" style="margin-right:30px;"><a href="#" onclick="DeleteAlert(); return false;">Non</a></div> ';
		MakingAlert("Confirmer", text);
	}
</script>

<div class="block-800">
<h2 class="ThemeLettre">Carte d'identité RolePlay:</h2>
<form>
	<div style="background-image:url('http://www.ts-x.eu/do/card/{steamid}/small.jpg'); width:753px; height:297px; margin-left:auto;margin-right:auto;">
		<div style="position:absolute; margin-top:153px; margin-left:265px;">
			<input type="text" name="nom" id="inputNom" />
		</div>
		<div style="position:absolute; margin-top:173px; margin-left:290px;">
			<input type="text" name="prenom" id="inputPrenom" />
		</div>
		<div class="inputButton" style="position:absolute; margin-top:245px; margin-left:210px; width:150px; height:30px; line-height:30px; text-align:center;" onclick="ValidationID();"> Postuler </div>
	</div>
</form>
</div>
