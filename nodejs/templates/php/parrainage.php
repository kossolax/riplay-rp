<?php
	if( isset($_GET['reward']) && $_GET['type'] == 'money' ) {
		$fieuil = mysql_real_escape_string($_GET['reward']);
		$req = mysql_query("SELECT * FROM `rp_csgo`.`rp_parrain` WHERE `steamid`='".$fieuil."' AND `parent`='".str_replace("STEAM_0", "STEAM_1", $user->data['steamid'])."' AND `approuved`='1' LIMIT 1");

		if( $row = mysql_fetch_array($req) ) {
			mysql_query("UPDATE `rp_csgo`.`rp_parrain`  SET `approuved`='2' WHERE `steamid`='".$fieuil."' LIMIT 1");
			mysql_query("INSERT INTO `rp_csgo`.`rp_users2` (`steamid`,`bank`) VALUES ('".$user->data['steamid']."', '100000');");
		}

		header("Location: /index.php?page=parrainage");
		exit;
	}
        if( isset($_GET['reward']) && $_GET['type'] == 'xp' ) {
                $fieuil = mysql_real_escape_string($_GET['reward']);
                $req = mysql_query("SELECT * FROM `rp_csgo`.`rp_parrain` WHERE `steamid`='".$fieuil."' AND `parent`='".str_replace("STEAM_0", "STEAM_1", $user->data['steamid'])."' AND `approuved`='1' LIMIT 1");

                if( $row = mysql_fetch_array($req) ) {
                        mysql_query("UPDATE `rp_csgo`.`rp_parrain`  SET `approuved`='3' WHERE `steamid`='".$fieuil."' LIMIT 1");
                        mysql_query("INSERT INTO `rp_csgo`.`rp_users2` (`steamid`, `xp`) VALUES ('".$user->data['steamid']."', '50000');");
                }

                header("Location: /index.php?page=parrainage");
                exit;
        }


	$steamid = str_replace("STEAM_0", "STEAM_1", $user->data['steamid']);
	mysql_select_db("rp_csgo");
	$sql = "UPDATE rp_parrain SET approuved='1' WHERE rp_parrain.`steamid` IN ( ";
	$sql .= "SELECT `steamid` FROM ( SELECT P.`steamid` FROM `rp_parrain` AS P INNER JOIN rp_idcard AS ID ON ID.`steamid`=P.`steamid` WHERE ID.`played`>'72000' AND P.`approuved`='0' ) ";
	$sql .= " AS coucou )";
	mysql_query($sql);

	$nbr1 = 0;
	$nbr2 = 0;

	$array = array();

	$req = mysql_query("SELECT name, approuved, rp_parrain.steamid FROM `rp_csgo`.rp_parrain INNER JOIN `rp_csgo`.rp_users ON rp_parrain.steamid=rp_users.steamid WHERE parent='".$steamid."' ORDER BY approuved DESC");
	while( $row = mysql_fetch_array($req) ) {
		$array[] = $row;

		if( $row['approuved'] == 1 )
			$nbr2++;
		else if( $row['approuved'] == 2 )
			$nbr2++;
		else
			$nbr1++;
	}

	mysql_query("UPDATE `rp_csgo`.`rp_success` SET `w_friends`='".$nbr2."', `w_friends2`='".$nbr2."', `w_friends3`='".$nbr2."' WHERE `SteamID`='".$steamid."'") or die(mysql_error());

	if( $nbr2 >= 5 ) {	mysql_query("UPDATE `rp_csgo`.`rp_success` SET `w_friends`='-1' WHERE `SteamID`='".$steamid."'"); }
	if( $nbr2 >= 10 ) {      mysql_query("UPDATE `rp_csgo`.`rp_success` SET `w_friends2`='-1' WHERE `SteamID`='".$steamid."'"); }
	if( $nbr2 >= 15 ) {      mysql_query("UPDATE `rp_csgo`.`rp_success` SET `w_friends3`='-1' WHERE `SteamID`='".$steamid."'"); }

	$tpl = new raintpl();
	$tpl->assign("list", $array);
	$tpl->assign("nbr1", $nbr1);
	$tpl->assign("nbr2", $nbr2);

	draw($tpl->draw("page_parrainage", $return_string=true), "Parrainage" );
?>
