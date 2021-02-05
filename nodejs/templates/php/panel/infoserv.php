<?php

        $query = mysql_query("SELECT * FROM `adm_serv` WHERE `uniq_id`='".mysql_real_escape_string($_GET['serv'])."' LIMIT 1;");
        $row = mysql_fetch_array($query);
        $info = array();
        infoServ(''.$row['ip'].'',  intval($row['port']), $info, 'cssource');

        $_PARSER = $info;
        foreach( $row as $key => $value ) {
                $_PARSER[$key] = $value;
        }

        $_PARSER['color'] = "00FF00";
        if( !isset($info['map']) ) {
                $_PARSER['hostname'] = "Hors-Ligne - ".$row['uniq_id']."";
                $_PARSER['color'] = "FF0000";
        }

	$query = mysql_query("SELECT * FROM `adm_logs` WHERE `uniq_id`='".mysql_real_escape_string($_GET['serv'])."' ORDER BY `id` DESC LIMIT 35;");
	while( $row = mysql_fetch_array($query) ) {
		$_PARSER['log'] .= "<div style=\"display: block;\" class=\"LogRow\"><span class=\"LogTime\">".strftime("%d/%m %H:%M:%S", $row['timestamp'])."</span> - <span class=\"LogSteamID\">".$row['username']."</span> - <span class=\"LogNickBLUE\">".$row['cmd']."</span></div>";
	}

        $tpl = gettemplate('admin_live_log_row');
	$_ROW = $_PARSER;
	$_ROW['is_only_one'] = ' LogLiveItselfExtented';

	$id = sha1( md5( uniqid( uniqid("loukou"), true) ) . md5( uniqid( uniqid("coucou"), true) ));
	$id = uniqid();

	mysql_query("UPDATE `phpbb3_users` SET `uniqid`='".$id."' WHERE `user_id`='".$user->data['user_id']."' LIMIT 1;");

//	usleep(100);

	if( $_PARSER['game'] == 'minecraft' )
		$_ROW['port'] = 20004;

	$_ROW['pass'] = $id;
	$_PARSER['live_log'] .= parsetemplate($tpl, $_ROW);

        $script = array( "admin");

	display( parsetemplate( gettemplate('panel/infoserv'), $_PARSER), 'Panel: Accueil', 'Admin', 'location_admin', $script);
?>
