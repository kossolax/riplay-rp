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

	if( isset($_GET['filtre']) ) {
		$_PARSER['filtre'] = $_GET['filtre'];
		$_PARSER['log'] = '';
		$filtre = PreventHack($_GET['filtre']);

if( group_memberships(19, $user->data['user_id'], true) ) {
		$cmd = 'find '.$row['dir'].''.$row['exec_game'].'/logs/* -exec grep "'.$filtre.'" \'{}\' \; -print | grep -v "'.$row['dir'].''.$row['exec_game'].'/logs/" | grep -v "/home/kossolax/" | grep -v " triggered \"clantag\"" | sort';
}
else {
                $cmd = 'find '.$row['dir'].''.$row['exec_game'].'/logs/* -exec grep "'.$filtre.'" \'{}\' \; -print | grep -v "'.$row['dir'].''.$row['exec_game'].'/logs/" | grep -v "/home/kossolax/" | grep -v " triggered \"clantag\"" | grep -v "Loading userdata" | sort';
}
set_time_limit(60);
		exec($cmd, $output);
		foreach( $output as $line ) {
			$_PARSER['log'] .= "".PreventBug($line)."<br />\n";
		}
	}
        display( parsetemplate( gettemplate('panel/log'), $_PARSER), 'Panel: Log', 'Admin', 'location_admin');

function PreventHack( $str ) {
	$str = str_replace("|", "", $str);
        $str = str_replace("&", "", $str);
	$str = str_replace("\\", "", $str);
        $str = str_replace("'", "", $str);
        $str = str_replace('"', "", $str);
	$str = str_replace('[', "\[", $str);
	$str = str_replace(']', "\]", $str);

	$str = str_replace('\\\\', "\\", $str);

        return $str;
}

function PreventBug( $str ) {
	$str = str_replace("<", "&lt;", $str);
	$str = str_replace(">", "&gt;", $str);
	$str = str_replace("LoXa139op", "", $str);

	return $str;
}
?>
