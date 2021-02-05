<?php

if( $user->data['user_id'] == ANONYMOUS ) {
	error_box("Erreur", "Vous devez vous connecter pour acceder a cette page.");
	exit;
}
if( $user->data['steamid'] == 'notset' || $user->data['steamid'] == '' ) {
	error_box("Erreur", "Vous etes bannis d'un de nos serveurs, et n'avez pas acces a cette page.");
	exit;
}

$user->data['steamid'] = str_replace("STEAM_0", "STEAM_1", $user->data['steamid']);

mysql_query("DELETE FROM `rp_csgo`.`rp_success` WHERE `SteamID`='".$user->data['steamid']."' LIMIT 1;");
error_box("RAZ", "SUCCES RAZ LOL");
exit;
?>
