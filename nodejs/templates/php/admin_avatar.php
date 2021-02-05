<?php

	$script = array();
	$script[] = "avatar";

	$_PARSE['pseudo'] = $user->data['username'];
        display( parsetemplate( gettemplate('admin_avatar'), $_PARSE), 'Team Avatar', 'Admin', 'location_admin', $script);
?>
