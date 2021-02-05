<?php
	$tpl = new raintpl();
	$tpl->assign('steamid', str_replace("STEAM_0", "STEAM_1", $user->data['steamid']));
	$tpl->assign('isAdmin', ((group_memberships(19, $user->data['user_id'], true) || group_memberships(18, $user->data['user_id'], true))?1:0));

	ob_start();
	include("/var/www/ts-x/web/leeth/DevZone/index_embeded.php");
	$str = ob_get_contents();
	ob_end_clean();

	draw($str, "dev-zone");

?>
