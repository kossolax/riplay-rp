<?php

if( $user->data['user_id'] == ANONYMOUS ) {
	error_box("Erreur", "Vous devez être connecté pour accèder à cette page.", "index.php");
	exit;
}

$tpl = new raintpl();

if( !empty($user->data['partner']) && !empty($user->data['tokken']) )
  $tpl->assign("link", "https://steamcommunity.com/tradeoffer/new/?partner=".$user->data['partner']."&token=".$user->data['tokken']."");
draw($tpl->draw("page_trade", $return_string=true), "Mise à jour" );

?>
