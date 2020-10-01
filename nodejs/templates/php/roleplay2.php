<?php
	$tpl = new raintpl();
	$tpl->assign('steamid', str_replace("STEAM_0", "STEAM_1", $user->data['steamid']));
	$tpl->assign('isAdmin', ((group_memberships(19, $user->data['user_id'], true) || group_memberships(18, $user->data['user_id'], true))?1:0));

	draw($tpl->draw("page_roleplay", $return_string=true), "roleplay", array( "angular.route.min.js", "heatmap.min.js", "jquery.maphilight.js", "angular.dnd.min.js" ) );

?>
