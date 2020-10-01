<?php

function nicetime($time) {
	return strftime("%e-%m-%Y à %H:%M", $time  );
}
function DisplaySteam($steam) {
	return "<a href=\"http://steamcommunity.com/profiles/".GetFriendID($steam)."\">".$steam."</a>";

}


$tpl = new raintpl();
$nicks = getNick();

if( !isset( $_GET['max'] ) )
	$_GET['max'] = 0;

$max = intval($_GET['max']);
$lookat = mysql_real_escape_string($_GET['lookat']);

$count = array();
$req = mysql_query("SELECT COUNT(*) as val, `steamid` FROM `srv_bans` GROUP BY `steamid`");
while( $row = mysql_fetch_array($req) ) {
	$count[$row['steamid']] = $row['val'];
}

if( isset($_GET['lookat']) AND strlen($lookat) > 1) {
	$sql = "SELECT * FROM `srv_bans` WHERE (`SteamID`='".$lookat."' OR `game`='".$lookat."' OR `adminSteamID`='".$lookat."' OR `BanReason` LIKE '%".$lookat."%') AND `is_hidden`='0' ORDER BY `srv_bans`.`id` DESC;;";
}
else {
	$sql = "SELECT * FROM `srv_bans` WHERE (`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0' AND `is_hidden`='0' ORDER BY `srv_bans`.`id` DESC LIMIT ".(0+(50*$max)).", 50;";
}
$req = mysql_query($sql);
$data = "";
$i = 1;


while( $row = mysql_fetch_array($req) ) {
	$row['nick'] = utf8_decode($nicks[$row['SteamID']]);
	$row['admin'] = utf8_decode($nicks[$row['adminSteamID']]);
	$row['score'] = $count[$row['SteamID']];
	$dataBase[] = $row;
}

$tpl = new raintpl();
$tpl->assign("row", $dataBase);
$tpl->assign("max", $max);
$tpl->assign("lookat", $_GET['lookat']);

        if( $max > 0 ) {
                $_PARSE['news_recent'] = '<a href="?page=bannis&max='.($max-1).'">Plus r&eacute;cent</a>';
        }
        if( $low_id != 1 ) {
                $_PARSE['news_vieux'] = '<a href="?page=bannis&max='.($max+1).'">Plus ancien</a>';
        }

$script = array();
$admin_header = "";

if( group_memberships(19, $user->data['user_id'], true) || group_memberships(68, $user->data['user_id'], true) ||  group_memberships(129, $user->data['user_id'], true) || group_memberships(130, $user->data['user_id'], true) || group_memberships(132, $user->data['user_id'], true)) {
	$tpl->assign("admin", "1");

	if( $_POST ) {
		if( $user->data['steamid'] == "STEAM_0:1:30371405" )
			die("Toi, tu touches plus a cette ban-liste.");

		$_POST['steamid'] = str_replace("STEAM_1", "STEAM_0", $_POST['steamid']);
	}
	$admin_header = gettemplate('admin_bannis');

	if( $_POST && $_GET['action'] == 'remove' ) {
		$query = mysql_fetch_array(mysql_query("SELECT * FROM `srv_bans` WHERE `id`='".intval($_POST['id'])."' LIMIT 1;"));
/*		if( $query['adminSteamID'] != $user->data['steamid'] && $user->data['user_id'] != 2) {
			error_box("Erreur", "Impossible de supprimer un ban qui ne vous appartient pas.", "index.php?page=bannis");
			exit;
		}
*/		mysql_query("UPDATE `srv_bans` SET `DebanSteamID`='".$user->data['steamid']."', `DebanReason`='".mysql_Real_escape_string($_POST['reason'])."', `is_unban`='1' WHERE `id`='".intval($query['id'])."' LIMIT 1;");
		error_box("Supprimé", "Le ban de ".utf8_decode($nicks[$query['SteamID']])."(".$query['SteamID'].") a été supprimé.", "index.php?page=bannis");
	}
	else if( $_POST && $_GET['action'] == 'add' ) {
		$query = "INSERT INTO `srv_bans` (`id`, `SteamID`, `StartTime`, `EndTime`, `Length`, `adminSteamID`, `BanReason`, `game`) VALUES ";
		$query .= "(NULL, '".mysql_real_escape_string(trim($_POST['steamid']))."', UNIX_TIMESTAMP(), (UNIX_TIMESTAMP()+'".(intval($_POST['time'])*60)."'),";
		$query .= " '".(intval($_POST['time'])*60)."', '".$user->data['steamid']."', '".mysql_real_escape_string($_POST['reason'])."', '".mysql_real_escape_string($_POST['game'])."'); ";
		mysql_query($query);

		if( $_POST['game'] == 'tribunal' ) {
			mysql_query("INSERT INTO `rp_csgo`.`rp_users2` (`id`, `steamid`, `jail`) VALUES (NULL, '".mysql_real_escape_string($_POST['steamid'])."', '".(intval($_POST['time'])*60)."' );");
		}
		if( $_POST['game'] == 'forum' || $_POST['game'] == 'ALL' ) {
			mysql_query("DELETE S FROM `ts-x`.`phpbb3_sessions` AS S INNER JOIN `ts-x`.`phpbb3_users` U ON S.`session_user_id`=U.`user_id` INNER JOIN `ts-x`.`srv_bans` B ON U.`steamid`=B.`steamid` WHERE (`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0' AND (`game`='forum' OR `game`='ALL')");
		}

		if( $_POST['game'] == 'teamspeak' || $_POST['game'] == 'ALL' ) {
			$req = mysql_query("SELECT `client_id` FROM `TeamSpeak`.`clients` WHERE `steamid`='".mysql_real_escape_string($_POST['steamid'])."';") or die(mysql_error());
			$errno = $errstr = 0;
			$socket = fsockopen("ts.ts-x.eu", 10011, $errno, $errstr, 50);
			if($errno == 0) {
			        fgets($socket);
				fputs($socket, "login tsxbot XGtPA5hA\n");
			        fgets($socket);
			        fputs($socket, "use sid=1\n");
			        fgets($socket);
			        fputs($socket, "clientupdate client_nickname=ts-x.eu\n");
			        fgets($socket);
				fputs($socket, "clientlist\n");
				fgets($socket);
				$data = fgets($socket);
				$data = explode("|", $data);
				$client = array();
				foreach($data as $key => $value) {
					$val2 = explode(" ", $value);
					$client[ str_replace("client_database_id=", "", $val2[2]) ] = str_replace("clid=", "", $val2[0]);
				}

				while( $row = mysql_fetch_array($req) ) {
				        fputs($socket, "servergroupdelclient sgid=7 cldbid=".$row[0]."\n");
					fgets($socket);
					if( isset($client[ $row[0] ]) ) {
						fputs($socket, "clientkick reasonid=5 clid=".$client[$row[0]]." reasonmsg=banned\n");
						fgets($socket);
					}
				}
	       		 	fputs($socket, "quit\n");
	        		fgets($socket);
	        		fclose($socket);
			}
		}

		error_box("Bannis", "".utf8_decode($nicks[$_POST['steamid']])."(".mysql_real_escape_string($_POST['steamid']).") a été bannis.", "index.php?page=bannis");
	}

}

draw($tpl->draw("page_bannis", $return_string=true), "Liste des bannis" );


?>

