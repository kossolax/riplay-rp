<?php

if( $user->data['user_id'] == ANONYMOUS ) {
        error_box("Erreur", "Vous devez vous connecter pour acceder a cette page.");
        exit;
}

if( $user->data['steamid'] == 'notset' || $user->data['steamid'] == '' ) {
        error_box("Erreur", "Vous devez vous connecter pour acceder a cette page.");
        exit;
}

$query = mysql_query("SELECT * FROM `srv_bans` WHERE `SteamID`='".$user->data['steamid']."' AND (`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0' AND `game`<>'whitelist';");
while( $row2 = mysql_fetch_array($query) ) {
        error_box("Erreur", "Vous etes bannis d'un de nos serveurs, et n'avez pas acces a cette page.");
        exit;
}


$tpl = new raintpl();
$tpl->assign('steamid', str_replace("STEAM_0", "STEAM_1",$user->data['steamid']));
draw($tpl->draw("page_report", $return_string=true), "Plainte téléphone", array( "angular.min.js" ) );
?>
