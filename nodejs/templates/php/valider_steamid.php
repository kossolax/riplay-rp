<?php
if ($user->data['user_id'] == ANONYMOUS) {
	error_box("Vous devez être connecté pour valider votre SteamID", "index.php");
	exit;
}

	$tpl = new raintpl();
	draw($tpl->draw("page_valider_steamid", $return_string=true), "Validation du SteamID");
?>
