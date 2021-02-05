<?php
if( isset($_SERVER['argc']) ) {
	require_once('/var/www/ts-x/gameq/gameserver_1.php');
	mysql_connect("athos.ts-x.eu", "kossolax", "QTpAbKfu5X5NupCBAE4tH3bL");
	mysql_select_db("ts-x");

	$req = mysql_query("SELECT * FROM `adm_serv`;");
	$count = 0;

	while($row = mysql_fetch_array($req) ) {

		if( $row['lastcheck'] < (time()-60) ) {
			infoServ(''.$row['ip'].'', $row['port'], $info, 'cssource');
			if( isset($info['map']) && $info['num_players'] >= 0 ) {
				$count += $info['num_players'];
	      mysql_query("UPDATE `adm_serv` SET `is_on`='1',`lastcheck`='".time()."',`current`='".$info['num_players']."' WHERE `uniq_id` = '".$row['uniq_id']."' LIMIT 1;");
			}
			else {
				mysql_query("UPDATE `adm_serv` SET `is_on`='0',`lastcheck`='".time()."',`current`='0' WHERE `uniq_id` = '".$row['uniq_id']."' LIMIT 1;");
			}
		}
		else {
			if( $row['current'] > 0 && $row['current'] <= 128 )
				$count += $row['current'];
		}
	}

/*
	$cache = "/var/www/ts-x/cache/gameq/ts.txt";
	$expire = time() - 15;
	if(file_exists($cache) && filemtime($cache) > $expire ) {
		$count += unserialize(	file_get_contents($cache) );
	}
	else {
		$errno = $errstr = 0;
    $socket = fsockopen("ts.ts-x.eu", 10011, $errno, $errstr, 10);
    if($errno == 0) {
			fgets($socket);
			fputs($socket, "login tsxbot XGtPA5hA\n");
			fgets($socket);
    	fputs($socket, "use sid=1\n");
    	fgets($socket);
    	fputs($socket, "serverinfo\n");
			$vars = fgets($socket);
			$vars = fgets($socket);
			fputs($socket, "exit\n");
			fgets($socket);
			fclose($socket);
			$var1 = explode(" ", $vars);
			$now = explode("=", $var1[7]);
			$max = explode("=", $var1[5]);
			$n = intval($now[1]);

			if( $n > 0 && $n <= 250 ) {
				$count += $n;
				file_put_contents($cache, serialize($n) );
			}
		}
	}
*/
	mysql_query("UPDATE `phpbb3_config` SET `config_value`='".$count."' WHERE `config_name`='player_count';");
	echo $count;
	exit;
}

function getSocket($host, $port, $errno, $errstr, $timeout) {
        global $errno, $errstr;
        $socket = fsockopen($host, $port, $errno, $errstr, $timeout);
        if(!$socket or fgets($socket, 3) != "TS3") {
                return false;
        }
        return $socket;
}
function sendQuery($socket, $query) {
        fputs($socket, $query."\n");
}
function closeSocket($socket) {
        fputs($socket, "quit\n");
        fclose($socket);
}

	$tpl = new raintpl();
	$req = mysql_query("SELECT * FROM `adm_serv` WHERE `is_on`=1 ORDER BY port ASC;");

	$rev = "cstrike";

	$array = array(); $i=0;
	while($row = mysql_fetch_array($req) ) {

		infoServ(''.$row['ip'].'', $row['port'], $info, 'cssource');
		$info['game'] = "csgo";
		$info['url'] = str_replace("/", "_", $info['map']);

		if( $info['ip'] == "176.31.38.177" )
			$info['game'] = "tf2";

		$array[] = $info;
	}
	$tpl->assign("row", $array);
	//display( parsetemplate( gettemplate('page_serveur_row'), $_PARSE), 'Liste des serveurs', 'Serveurs', 'location_serveur');

	draw($tpl->draw("page_serveur", $return_string=true), "roleplay");
?>
