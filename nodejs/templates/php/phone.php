<?php

header("Location: index.php?page=report");
exit;

if( $user->data['user_id'] == ANONYMOUS ) {
        error_box("Erreur", "Vous devez vous connecter pour acceder a cette page.");
        exit;
}

if( $user->data['steamid'] == 'notset' || $user->data['steamid'] == '' ) {
	error_box("Erreur", "Vous devez vous connecter pour acceder a cette page.");
        exit;
}

$query = mysql_query("SELECT * FROM `srv_bans` WHERE `SteamID`='".$user->data['steamid']."' AND (`Length`='0' OR `EndTime`>UNIX_TIMESTAMP()) AND `is_unban`='0';");
while( $row2 = mysql_fetch_array($query) ) {
        error_box("Erreur", "Vous etes bannis d'un de nos serveurs, et n'avez pas acces a cette page.");
        exit;
}

$user->data['steamid'] = str_replace("STEAM_0", "STEAM_1", $user->data['steamid']);

if( $_POST ) {

	if( $_POST['message_id'] ) {
		$id = intval($_POST['message_id']);
		$owner = mysql_fetch_array(mysql_query("SELECT * FROM `rp_csgo`.`rp_messages` WHERE `id`='".$id."';"));

		$to = array();
		$to[] = $owner['steamid'];
		$r = mysql_query("SELECT `steamid` FROM `rp_csgo`.`rp_messages_seen` WHERE `messageid`='".$id."';");
		while( $row = mysql_fetch_array($r) ) {
			$to[] = $row['steamid'];
		}

		$to = array_diff($to, array($user->data['steamid']));
		$to = array_unique($to);
		$_POST['title'] = "Re: ".$owner['title'];
		$linked = "'".$owner['id']."'";
	}
	else {
		$to = mysql_real_escape_string(rtrim(trim($_POST['sendTo']), ","));
		if( strlen($to) < 5 ) {
			error_box("Envoy&eacute;", "Pas de destinataire", "/index.php?page=phone");
			exit;
		}
		$to = str_replace("STEAM_0", "STEAM_1", $to);
	        $to = str_replace(" ", "", $to);
	        $to = explode(",", $to);
		$to = array_unique($to);

		if( $to[0] == "POLICE" ) {
			foreach($to as $s => $value) {
				if( $s != 0 && $value == "POLICE" ) {
					error_box("Erreur", "Vous devez mettre plainte police suivit du pseudo du ou des policiers en question", "/index.php?page=phone");
					exit;
				}
			}
			$to = array_diff($to, array("POLICE"));
			$to[] = "POLICE-".implode("-", $to);

			$r = mysql_query("SELECT steamid FROM `rp_csgo`.`rp_users` WHERE `job_id` IN (1,2,101,102) OR `refere` = 1");
			while( $row = mysql_fetch_array($r) ) {
				$to[] = $row['steamid'];
			}
			$to = array_diff($to, array($user->data['steamid']));
			$to = array_unique($to);
		}
		$linked = "NULL";
	}

	$title = mysql_real_escape_string(strip_tags(trim($_POST['title'])));
	$msg = mysql_real_escape_string(strip_tags(trim($_POST['msg'])));

	$req = "INSERT INTO `rp_csgo`.`rp_messages` (`id`, `title`, `text`, `timestamp`, `steamid`, `linked_to`) VALUES ";
	$req .= "(NULL, '".$title."', '".$msg."', UNIX_TIMESTAMP(), '".mysql_real_escape_string($user->data['steamid'])."', ".$linked.");";
	mysql_query($req);

	$id = mysql_insert_id();

	foreach( $to as $s ) {
		$req = "INSERT INTO `rp_csgo`.`rp_messages_seen` (`id`, `messageid`, `steamid`, `seen`) VALUES ";
		$req .= "(NULL, '".$id."', '".$s."', '0');";
		mysql_query($req);
	}
	error_box("Envoy&eacute;", "Votre message a bien &eacute;t&eacute; envoy&eacute;.", "/index.php?page=phone");
	exit;
}

if( $_GET['search'] ) {
	$s = mysql_real_escape_string(trim($_GET['search']));
	$req = "SELECT steamid, name, job_name FROM `rp_csgo`.`rp_users` U ";
	$req .= "INNER JOIN `rp_csgo`.`rp_jobs` J ON J.job_id=U.job_id ";
	$req .= "WHERE `name` LIKE '%".$s."%' OR `job_name` LIKE '%".$s."%' ORDER BY `time_played` DESC LIMIT 50";
	$r = mysql_query($req) or die( mysql_error());

	$data = array();
	$i = 0;
	while( $row = mysql_fetch_array($r) ) {
		$data[$i]['steamid'] = $row['steamid'];
		$data[$i]['name'] = $row['name'];
		$data[$i]['job'] = $row['job_name'];
		$i++;
	}
	echo json_encode($data);
	exit;
}

$tpl = new raintpl();

if( $_GET['viewID'] ) {

	$req = "SELECT `messageid`,`linked_to` FROM `rp_csgo`.`rp_messages_seen` MS";
	$req .= " INNER JOIN `rp_csgo`.`rp_messages` M ON M.id=MS.messageid";
	$req .= " WHERE (MS.`steamid`='".$user->data['steamid']."' OR M.`steamid`='".$user->data['steamid']."')";
	$req .= " AND MS.`id`='".intval($_GET['viewID'])."' LIMIT 1";

	$r = mysql_query($req) or die(mysql_error());
	$origin = mysql_fetch_array($r);
	if( $origin['linked_to'] == NULL )
		$origin = $origin['messageid'];
	else
		$origin = $origin['linked_to'];

	$req = "SELECT M.*, U.`name`, MS.*, U2.`name` as `targetName`, MS.steamid as inSteam, M.steamid as outSteam FROM (";
	$req .= "	SELECT x1.* from `rp_messages` x1";
	$req .= "		WHERE x1.`linked_to`='".$origin."'";
	$req .= "	UNION";
	$req .= "	SELECT x2.* from `rp_messages` x2";
	$req .= "               WHERE x2.`id`='".$origin."'";
	$req .= "	";
	$req .= ") AS M";
	$req .= "    LEFT JOIN `rp_users` U ON U.`steamid`=M.`steamid`";
	$req .= "    LEFT JOIN `rp_messages_seen` MS ON MS.messageid=M.id";
	$req .= "    LEFT JOIN `rp_users` U2 ON U2.`steamid`=MS.`steamid`";
	$req .= "	ORDER BY `timestamp` DESC";

	$res = array();

	mysql_select_db("rp_csgo");
	$r = mysql_query($req) or die(mysql_error());
	while( $row = mysql_fetch_array($r) ) {

		$row['text'] = nl2br($row['text']);
		if( $row['inSteam'] == $user->data['steamid'] ) {
			mysql_query("UPDATE `rp_csgo`.`rp_messages_seen` SET `seen`='1' WHERE `id`='".$row['id']."'");
		}
		if( $row['inSteam'] != $user->data['steamid'] &&
		    $row['outSteam'] != $user->data['steamid'] ) {
			continue;
		}
		$row['text'] = nl2br($row['text']);
		$res[$row['messageid']] = $row;
	}
	$req = "SELECT `name`, MS.`steamid` FROM `rp_messages_seen` MS ";
	$req .= "LEFT JOIN `rp_users` U ON U.`steamid`=MS.`steamid` ";
	$req .= "WHERE MS.`messageid`='".$origin."'";
	$r = mysql_query($req) or die(mysql_error());
	$sender = array();
	while($row = mysql_fetch_array($r) ) {
		if( $row['steamid'] == $user->data['steamid'] )
			continue;
		$sender[] = $row['name'];

		if ( strpos($row['steamid'],'POLICE') !== false) {
			$dat = array();
			$dat['flute'] = md5(uniqid());
			$dat['time'] = time();
			$dat['data'] = explode("-", $row['steamid']);
			setcookie("bypass", encode(serialize( $dat ), "pomme"), time()+(15*60));
			$tpl->assign("police", explode("-", $row['steamid']));
		}
	}
	$tpl->assign("parti", implode($sender, ", "));

	mysql_select_db("ts-x");
	$tpl->assign("showMsg", $res);
	$tpl->assign("origin", $origin);
}

$req = "SELECT M.*, MS.steamid as inSteam, M.steamid as outSteam, MS.seen, U.`name`, U2.`name` as `targetName`, MS.`id`";
$req .= " FROM `rp_csgo`.`rp_messages_seen` MS";
$req .= " INNER JOIN `rp_csgo`.`rp_messages` M ON M.`id`=MS.`messageID`";
$req .= " INNER JOIN `rp_csgo`.`rp_users` U ON U.`steamid`=M.`steamid`";
$req .= " INNER JOIN `rp_csgo`.`rp_users` U2 ON U2.`steamid`=MS.`steamid`";
$req .= " WHERE MS.`steamid`='".$user->data['steamid']."' OR M.`steamid`='".$user->data['steamid']."'";
$req .= " ORDER BY MS.`id` DESC LIMIT 250;";

$query = mysql_query($req) or die(mysql_error());
$in = array();
$out = array();
$count = 0;
while( $row = mysql_fetch_array($query) ) {
	$row['title'] = _substr($row['title'], 40);
        $row['text'] = _substr($row['text'], 60-strlen($row['title']));

	if( $row['inSteam'] == $user->data['steamid'] ) {
		if( $row['seen'] == 0 )
			$count++;
		$in[] = $row;
	}
	if( $row['outSteam'] == $user->data['steamid'] ) {
                $out[] = $row;
        }

}


$tpl->assign("inbox", $in);
$tpl->assign("outbox", $out);

$tpl->assign("count", $count);
$tpl->assign("type", $_GET['type']);

draw($tpl->draw("page_phone", $return_string=true), "T&eacute;l&eacute;phone", array("typeahead.bundle.min.js") );


?>
