<div class="block-800">
<h2 class="BorderBottom">Générer votre avatar:</h2>
<form><table>
<tr>
	<td width="200">Pseudo:</td>
	<td width="250">Type:</td>
	<td width="250">Police:</td>
	<td width="100">Couleur:</td>
	<td width="50"></td>
</tr><tr>
	<td>
		<input id="gen_avatar_pseudo" name="pseudo" value="{pseudo}" type="text" onchange="UpdateTeamAvatar();"/>
	</td>
	<td>
		<select id="gen_avatar_type" name="type" class="InputFile" onchange="UpdateTeamAvatar();">
			<option value="aigle"> Aigle1 </options>
                        <option value="aigle2"> Aigle2 </options>
                        <option value="dragon"> Dragon </options>
                        <option value="lion"> Lion </options>
                        <option value="loup"> Loup </options>
                        <option value="requin"> Requin </options>
                        <option value="tigre"> Tigre </options>
			<option value="tigre2"> Tigre 2 </options>
			<option value="taureau"> Taureau </options>
			<option value="serpent"> Serpent </options>
			<option value="poisson"> Poisson </options>
			<option value="glouglou"> Pelican </options>
			<option value="ours"> Ours </options>
			<option value="cheval"> Cheval </options>
			<option value="lapin"> Lapin </options>
			<option value="renard"> Renard </options>
			<option value="renard2"> Renard 2 </options>
			<option value="croco"> Crocodil </options>
			<option value="diable"> Diabolo </options>
			<option value="mort"> Mort </options>
			<option value="gorille"> Gorille </options>
			<option value="scorpion"> Scorpion </options>
		</select>
	</td>
	<td>
                <select id="gen_avatar_police" name="font" class="InputFile" onchange="UpdateTeamAvatar();">
                        <option default value="StAndrew"> StAndrew </options>
			<option value="BLOODY"> BlooDy </options>
			<option value="calibri"> Calibri </options>
			<option value="coldnightforalligators"> ColdNight </options>
			<option value="comic"> Comic </options>
			<option value="deadkansas"> DeadKansas </options>
			<option value="defused"> Defused </options>
			<option value="DejaVuSans"> DejaVuSans </options>
			<option value="fightingspiritTBS"> FightingSpirit </options>
			<option value="FromWhereYouAre"> FromWhere </options>
			<option value="PEPSI_pl"> PEPSI </options>
			<option value="StAndrew"> StAndrew </options>
			<option value="tahoma"> Tahoma </options>
			<option value="verdana"> Verdana </options>
                </select>
	</td>
	<td>
		<select id="favcolor" class="InputFile" onchange="UpdateTeamAvatar();">
                        <option default value="rouge"> Rouge </options>
			<option value="bleu"> Bleu </options>
			<option value="fushia"> Fushia </options>
			<option value="violet"> Violet </options>
			<option value="jaune"> Jaune </options>
			<option value="vert"> Vert </options>
                </select>
	</td>
	<td alight="right">
		<a href="#" onclick="UpdateTeamAvatar(); return false;"> Générer </a>
	</td>
</tr><tr>
	<td colspan="4"><br /><br /></td>
</tr><tr>

	<td><h3>Résultat:</h3></td>
	<td><div id="gen_avatar_result_img"></div></td>
	<td colspan="2"><div id="gen_avatar_cache"></div> <input id="gen_avatar_result_url" type="text" size="50" /></td>
</tr>	
</table></form>

<script>
	UpdateTeamAvatar();
</script>
</div>
<br />

