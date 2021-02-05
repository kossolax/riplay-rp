<?php

if( $user->data['user_id'] == ANONYMOUS ) {
	error_box("Erreur", "Vous devez vous connecter pour acceder a cette page.");
	exit;
}

$query = mysql_query("SELECT * FROM `srv_bans` WHERE `SteamID`='".$user->data['steamid']."' AND (`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0' AND `game`<>'whitelist';");
while( $row2 = mysql_fetch_array($query) ) {
	error_box("Erreur", "Vous etes bannis d'un de nos serveurs, et n'avez pas acces a cette page.");
	exit;
}

if( $user->data['steamid'] == 'notset' || $user->data['steamid'] == '' ) {
	error_box("Erreur", "Vous etes bannis d'un de nos serveurs, et n'avez pas acces a cette page.");
	exit;
}


$tpl = new raintpl();
$tpl->assign("nick", ltrim(substr(preg_replace("/[^a-zA-Z0-9]+/", "", $user->data['username']), 0, 15), "0123456789"));

if(	group_memberships(19, $user->data['user_id'], true) || group_memberships(18, $user->data['user_id'], true)) {
	$tpl->assign("pass", substr(md5($user->data['password_clean']), 5, 20));
}

draw($tpl->draw("page_irc", $return_string=true), "IRC", array( "angular.min.js" ));

?>
