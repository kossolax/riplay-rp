<?php

$tpl = new raintpl();

if( 	group_memberships(19, $user->data['user_id'], true) ||
      group_memberships(18, $user->data['user_id'], true)) {
	// Si admin
}


$tpl->assign("coucou", $user->data['username']);
draw($tpl->draw("page_maj", $return_string=true), "Mise à jour" );

?>