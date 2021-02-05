<?php
define('GIVE_MONEY', 10000);

if( $user->data['user_id'] == ANONYMOUS ) {
	if( isset($_GET['steamid']) ) {
		setcookie("steamid", $_GET['steamid'], time()+1000 );
		$_COOKIE["steamid"] = $_GET['steamid'];
	}

	if( isset($_COOKIE["steamid"]) ) {
		$user->data['steamid'] = mysql_real_escape_string($_COOKIE["steamid"]);
	}
	else {
	        error_box("Erreur", "Vous devez être connecté pour accèder à cette page.", "index.php");
		exit;
	}
}
include('forum/validate_steamid.php');
$tpl = new raintpl();
$tpl->assign("steamid", $user->data['steamid']);
draw($tpl->draw("page_money", $return_string=true), "Achat de $RP" );

?>
