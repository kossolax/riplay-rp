<?php

if( $user->data['steamid'] != 'STEAM_0:0:7490757' && $user->data['steamid'] != 'STEAM_0:1:39278818' && $user->data['steamid'] != 'STEAM_0:1:47011739' ) {
	die("Nope");
}

	$steamid = mysql_real_escape_string($_GET['steamid']);
	$steamid0 = str_replace("STEAM_1", "STEAM_0", $steamid);
	$steamid1 = str_replace("STEAM_0", "STEAM_1", $steamid);

	if( $_GET['sub'] == 'nopyj' ) {

		mysql_query("UPDATE `phpbb3_users` SET `no_pyj`='1' WHERE `steamid`='".$steamid0."';") or die(mysql_error());
		mysql_query("UPDATE `phpbb3_users` SET `no_pyj`='1' WHERE `steamid`='".$steamid1."';") or die(mysql_error());


		error_box('Fait', 'La personne a été définis comme non-pyjama.', $_SERVER['HTTP_REFERER']);
		exit;
	}
	if( $_GET['sub'] == 'REMOVEnopyj' ) {

		mysql_query("UPDATE `phpbb3_users` SET `no_pyj`='0' WHERE `steamid`='".$steamid0."';") or die(mysql_error());
		mysql_query("UPDATE `phpbb3_users` SET `no_pyj`='0' WHERE `steamid`='".$steamid1."';") or die(mysql_error());

		error_box('Fait', 'La personne a perdu son Rang NoPyj.', $_SERVER['HTTP_REFERER']);
  	exit;
  }

?>
