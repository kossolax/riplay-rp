<?php
$id = intval($_GET['sid']);
$ip = mysql_real_escape_string($_SERVER['REMOTE_ADDR']);

if( $user->data['user_id'] == ANONYMOUS || $user->data['steamid'] == 'notset' ) {
	$tpl = new raintpl();
	draw($tpl->draw("page_teamspeak", $return_string=true), "Erreur" );
	exit;
}

$steamid = $user->data['steamid'];

$sql = "SELECT * FROM `srv_bans` WHERE `SteamID`='".$steamid."' AND (`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0' AND (`game`='forum' OR `game`='ALL' OR `game`='teamspeak') LIMIT 1;";
$data = mysql_fetch_array(mysql_query($sql));
if( $data ) {
	$title = "Bannis";
	$message = "Vous avez été bannis de notre forum.<br /> Raison: ".$data['BanReason'].".<hr />étant donné que vous êtes bannis du forum, il est impossible de faire une demande pour annuler cette sanction.";
	$sql = "INSERT INTO `site_alert` (`id`, `owner`, `timestamp`, `titre`, `text`) VALUES (NULL , '".$user->data['user_id']."', '".time()."', '".mysql_real_escape_string($title)."', '".mysql_real_escape_string($message)."');";
	mysql_query($sql, $g_hBDD);
	$id = mysql_insert_id($g_hBDD);
	header('Location: http://www.ts-x.eu/index.php?page=bannis&lookat='.$steamid.'&errID='.$id.'');
	exit;
}


mysql_select_db("TeamSpeak");
$d = mysql_fetch_array(mysql_query("SELECT `client_lastip`, `client_nickname`, `client_unique_id`  FROM `clients` WHERE `client_id`='".$id."' LIMIT 1")) or die(mysql_error());
if( $d['client_lastip'] != $ip ) {
	error_box("TeamSpeak", "VPN: Votre ip sur votre navigateur: ".$ip.",  votre IP sur TeamSpeak: ".$d['client_lastip']."", "index.php");
	exit;
}

mysql_query("UPDATE `clients` SET `steamid`='".$user->data['steamid']."' WHERE `client_id`='".$id."' LIMIT 1") or die(mysql_error());
$errno = $errstr = 0;
$socket = fsockopen("ts.ts-x.eu", 10011, $errno, $errstr, 10);
if($errno == 0) {
	fgets($socket);
	fputs($socket, "login tsxbot XGtPA5hA\n");
	fgets($socket);
	fputs($socket, "use sid=1\n");
	fgets($socket);
	fputs($socket, "clientupdate client_nickname=ts-x.eu\n");
	fgets($socket);
	fputs($socket, "servergroupaddclient sgid=7 cldbid=".$id."\n");
	fgets($socket);
	fputs($socket, "quit\n");
	fgets($socket);
	fclose($socket);
}

$log = "".$user->data['steamid']." - ".$id." - ".$d['client_nickname']." - ".$d['client_unique_id']." - ".$user->data['steamid']." - ".date(DATE_RFC2822)."\n" . file_get_contents("/var/www/ts-x/cache/teamspeak.txt");
file_put_contents("/var/www/ts-x/cache/teamspeak.txt", $log);

error_box("TeamSpeak", "Bienvenue sur notre serveur TeamSpeak !", "index.php");

?>
