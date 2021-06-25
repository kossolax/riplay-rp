<?php

//	if( strpos($_SERVER['HTTP_USER_AGENT'], "en-US; Valve Client") === false && $_SERVER["REMOTE_ADDR"] != "85.27.115.39" && $_SERVER["REMOTE_ADDR"] != "109.88.16.4" )
	      die("hacking attmpt.");

if( $user->data['user_id'] == ANONYMOUS ) {
        error_box("Erreur", "Vous devez vous connecter pour acceder a cette page.");
        exit;
}

function getFAIL($val) {
	$val = intval($val);

	$str = "<strong>Erreur: </strong>";
	switch( $val ) {
		case 1: $str .= "Vous n'avez pas assez de ticket d'échange pour l'HDV.";       break;
		case 2: $str .= "Vous avez trop de vente active.";      break;
		case 3: $str .= "Vous n'avez pas assez d'objet de ce type dans votre inventaire.";      break;
		case 4: $str .= "T ES QUI POUR FAIRE CA?";      break;
		case 5: $str .= "Cette vente est temporairement désactivée.";   break;
		case 6: $str .= "Cet objet a été acheté avant vous et n'est plus disponible.";  break;
		case 7: $str .= "Vous n'avez pas assez d'argent.";      break;
		case 8: $str .= "Il est trop tôt pour annuler cette vente.";    break;
		case 9: $str .= "Impossible de retirer une voiture depuis l'HDV. Utilisez un garage.";    break;
		case 10: $str .= "La vente d'item PvP n'est pas possible depuis l'HDV.";    break;
	}

	return $str;
}

$tpl = new raintpl();

$items = array();
$jobs = array();
$byJob = array();
$allItems = array();
$dont_add = array(1, 101, 151, 161, 181);

$r = mysql_query("SELECT * FROM `rp_csgo`.`rp_items`");
while( $row = mysql_fetch_array($r) ) {
	$items[$row['id']] = $row;
	$taxe = 5;
	if( strstr($row['extra_cmd'], "rp_giveitem") !== false ) {
		$taxe = 10;
	}
	if( strstr($row['extra_cmd'], "rp_item_drug") !== false ) {
		$taxe = 15;
	}
	$items[$row['id']]['taxe'] = $taxe;
}
$r = mysql_query("SELECT * FROM `rp_csgo`.`rp_jobs` WHERE `is_boss`='1';");
while( $row = mysql_fetch_array($r) ) {
	$jobs[$row['job_id']] = $row;
}

$user->data['steamid'] = str_replace("STEAM_0", "STEAM_1", $user->data['steamid']);
if( $_SERVER["REMOTE_ADDR"] != "85.27.115.39" && $_SERVER["REMOTE_ADDR"] != "109.88.16.4" )
	$player = @mysql_fetch_array(mysql_query("SELECT * FROM `rp_csgo`.`rp_users` WHERE `steamid`='".$user->data['steamid']."' AND `last_connected` >= NOW() - INTERVAL 2 MINUTE LIMIT 1"));
else
	$player = @mysql_fetch_array(mysql_query("SELECT * FROM `rp_csgo`.`rp_users` WHERE `steamid`='".$user->data['steamid']."' LIMIT 1"));

$tpl->assign("jobs", $jobs);
$tpl->assign("items", $items);
$tpl->assign("denied", array(1, 101, 151, 161, 181));

if( !$player ) {
        error_box("Erreur", "Vous devez vous connecter pour acceder a cette page.");
        exit;
}

if( $_GET['action'] == 'item' ) {
	$data = explode(";", $player['in_bank']);
	foreach( $data as $row ) {
		$i = explode(",", $row);
		if( isset( $items[$i[0]]['job_id'] ) && ($i[1] > 0 || $i[0] == 42) ) {
			$byJob[ $items[$i[0]]['job_id'] ][] = $i;
			$allItems[ $i[0] ] = intval($i[1]);
		}
	}
	$tpl->assign("byJob", $byJob);
	$tpl->assign("allItems", $allItems);

	if( $_POST['action'] == "Vendre" ) {
		mysql_select_db("rp_csgo");

		$item = intval($_POST['item']);
		$amount = intval($_POST['amount']);
		$price = intval($_POST['price']);

		if( !isset($allItems[30]) || intval($allItems[30]) < 1 ) {
			if( $item == 30 ) {
				if( intval($allItems[30]) > $amount ) {
				}
				else {
				if( !($player['job_id'] >= 211 && $player['job_id'] <= 220) ) {
						header("Location: index.php?page=hdv&action=idle&erreur=1");
						exit;
					}
				}
			}
			else {
				if( !($player['job_id'] >= 211 && $player['job_id'] <= 220) ) {
					header("Location: index.php?page=hdv&action=idle&erreur=1");
					exit;
				}
			}
		}
		if( $amount < 0 || $amount > 1000 || $amount > intval($allItems[$item]) ) {
			header("Location: index.php?page=hdv&action=idle&erreur=3");
			exit;
		}
		if( $price < ($items[$item]['prix']/4) || $price > ($items[$item]['prix']*4) ) {
			header("Location: index.php?page=hdv&action=idle&erreur=4");
			exit;
		}
		if( $items == "rp_giveitem_pvp" || $items == "rp_item_spawnflag") {
			header("Location: index.php?page=hdv&action=idle&erreur=10");
			exit;
		}
		mysql_query("LOCK TABLES `rp_trade` WRITE, `rp_users2` WRITE");

		$req = "INSERT INTO `rp_trade` (`id`, `steamid`, `itemID`, `amount`, `price`, `time`) ";
		$req .= "VALUES (NULL, '".$user->data['steamid']."', '".$item."', '".$amount."', '".$price."', UNIX_TIMESTAMP());";
		mysql_query($req);
		$req = "INSERT INTO `rp_users2` (`id`, `steamid`, `itemid`, `itemAmount`,`pseudo`, `steamid2`, `timestamp`) VALUES ";
		$req .= "(NULL, '".$user->data['steamid']."', '".$item."', '-".$amount."', 'Depot HDV', 'SERVER', CURRENT_TIMESTAMP);";
		mysql_query($req);

		if( !($player['job_id'] >= 211 && $player['job_id'] <= 220) ) {
		$req = "INSERT INTO `rp_users2` (`id`, `steamid`, `itemid`, `itemAmount`,`pseudo`, `steamid2`, `timestamp`) VALUES ";
		$req .= "(NULL, '".$user->data['steamid']."', '30', '-1', 'Depot HDV', 'SERVER', CURRENT_TIMESTAMP);";
			mysql_query($req);
		}
		mysql_query("UNLOCK TABLES");

		header("Location: /index.php?page=hdv&action=idle");
		exit;
	}
	else if( $_POST ) {
		mysql_select_db("rp_csgo");
		$item = intval($_POST['item']);
                $amount = intval($_POST['amount']);
		if( $amount < 0 || $amount > 1000 || $amount > intval($allItems[$item]) ) {
			header("Location: index.php?page=hdv&action=idle&erreur=3");
			exit;
		}

		if( strstr($items[$item]['extra_cmd'], "rp_item_vehicle ") !== false ) {
			header("Location: index.php?page=hdv&action=idle&erreur=9");
			exit;
		}

		$req = "INSERT INTO `rp_users2` (`id`, `steamid`, `itemid`, `itemAmount`,`pseudo`, `steamid2`, `timestamp`) VALUES ";
                $req .= "(NULL, '".$user->data['steamid']."', '".$item."', '-".$amount."', 'Retrais banque', 'SERVER', CURRENT_TIMESTAMP);";
                mysql_query($req);

		$req = "INSERT INTO `rp_users2` (`id`, `steamid`, `itemid`, `itemAmount`, `itemToBank`, `pseudo`, `steamid2`, `timestamp`) VALUES ";
                $req .= "(NULL, '".$user->data['steamid']."', '".$item."', '".$amount."', '0', 'Retrais banque', 'SERVER', CURRENT_TIMESTAMP);";
                mysql_query($req);

		header("Location: /index.php?page=hdv&action=idle");
		exit;
	}
}
else if( $_GET['action'] == 'selling' ) {
	$req = mysql_query("SELECT * FROM `rp_csgo`.`rp_trade` WHERE `steamid`='".$user->data['steamid']."' ORDER BY `time` DESC;");

	while($row = mysql_fetch_array($req) ) {
		$allItems[] = $row;
	}
	$tpl->assign("allItems", $allItems);

	if( $_POST ) {
		mysql_select_db("rp_csgo");
		$uniqID = intval($_POST['item']);

		$req = mysql_query("SELECT * FROM `rp_trade` WHERE `done`='0' AND `id`='".$uniqID."' LIMIT 1;");
		if( !$req ) {
			header("Location: index.php?page=hdv&action=idle&erreur=6");
			exit;
		}
		$row = mysql_fetch_array($req);
		if( !$row ) {
			header("Location: index.php?page=hdv&action=idle&erreur=6");
			exit;
		}
		if( $row['steamid'] != $user->data['steamid'] ) {
			header("Location: index.php?page=hdv&action=idle&erreur=4");
			exit;
		}

		mysql_query("LOCK TABLES `rp_trade` WRITE, `rp_users2` WRITE");
		mysql_query("DELETE FROM `rp_trade` WHERE `id`='".$uniqID."' LIMIT 1;");

		$req = "INSERT INTO `rp_users2` (`id`, `steamid`, `itemid`, `itemAmount`,`pseudo`, `steamid2`, `timestamp`) VALUES ";
		$req .= "(NULL, '".$user->data['steamid']."', '".$row['itemID']."', '".$row['amount']."', 'annulation HDV', 'SERVER', CURRENT_TIMESTAMP);";
		mysql_query($req);

		mysql_query("UNLOCK TABLES");

		header("Location: index.php?page=hdv&action=idle");
		exit;
	}
}
else if( $_GET['action'] == 'buy' ) {
	$req = mysql_query("SELECT * FROM `rp_csgo`.`rp_trade` WHERE `done`='0' ORDER BY (price*amount) ASC;");
	while($row = mysql_fetch_array($req) ) {
		$byJob[ $items[ $row['itemID'] ]['job_id'] ][] = $row;
		$allItems[] = $row;
	}
	$tpl->assign("byJob", $byJob);
	$tpl->assign("allItems", $allItems);

	if( $_POST ) {
		$allItems = array();
		$data = explode(";", $player['in_bank']);
		foreach( $data as $row ) {
			$i = explode(",", $row);
			if( isset( $items[$i[0]]['job_id'] ) && ($items[$i[0]]['job_id'] > 0 || $i[0] == 42) ) {
				$byJob[ $items[$i[0]]['job_id'] ][] = $i;
				$allItems[ $i[0] ] = intval($i[1]);
			}
		}

		mysql_select_db("rp_csgo");
		$uniqID = intval($_POST['item']);
		$req = mysql_query("SELECT * FROM `rp_trade` WHERE `id`='".$uniqID."' AND `done`='0' LIMIT 1;");
		if( !$req ) {
			header("Location: index.php?page=hdv&action=idle&erreur=6");
			exit;
		}
		$row = mysql_fetch_array($req);
		if( !$row ) {
			header("Location: index.php?page=hdv&action=idle&erreur=6");
			exit;
		}
		if( ($player['money']+$player['bank']) < ($row['price']*$row['amount']) ) {
			header("Location: index.php?page=hdv&action=idle&erreur=7");
			exit;
		}
		if( !isset($allItems[30]) || intval($allItems[30]) < 1 ) {
			if( !($player['job_id'] >= 211 && $player['job_id'] <= 220) ) {
				header("Location: index.php?page=hdv&action=idle&erreur=1");
				exit;
			}
		}
		mysql_query("LOCK TABLES `rp_trade` WRITE, `rp_users2` WRITE");
		$req = "INSERT INTO `rp_users2` (`id`, `steamid`, `bank`,  `pseudo`, `steamid2`, `timestamp`) VALUES ";
		$reqA = $req . "(NULL, '".$user->data['steamid']."', '-".($row['price']*$row['amount'])."', 'achat HDV', 'SERVER', CURRENT_TIMESTAMP);";
		$reqV = $req . "(NULL, '".$row['steamid']."', '+".((($row['price']*$row['amount'])/100)*(100-$items[$row['itemID']]['taxe']))."', 'vente HDV', 'SERVER', CURRENT_TIMESTAMP);";

		mysql_query("UPDATE `rp_trade` SET `done`='1', `boughtBy`='".$user->data['steamid']."' WHERE `id`='".$uniqID."' LIMIT 1;");
		mysql_query($reqA) or die(mysql_error());
		mysql_query($reqV) or die(mysql_error());
		$req = "INSERT INTO `rp_users2` (`id`, `steamid`, `itemid`, `itemAmount`,`pseudo`, `steamid2`, `timestamp`) VALUES ";
		$req .= "(NULL, '".$user->data['steamid']."', '".$row['itemID']."', '".$row['amount']."', 'achat HDV', 'SERVER', CURRENT_TIMESTAMP);";
		mysql_query($req);
		if( !($player['job_id'] >= 211 && $player['job_id'] <= 220) ) {
			$req = "INSERT INTO `rp_users2` (`id`, `steamid`, `itemid`, `itemAmount`,`pseudo`, `steamid2`, `timestamp`) VALUES ";
			$req .= "(NULL, '".$user->data['steamid']."', '30', '-1', 'achat HDV', 'SERVER', CURRENT_TIMESTAMP);";
			mysql_query($req);
		}
		$req = "INSERT INTO `rp_users2` (`id`, `steamid`, `money`,`job_id`, `pseudo`, `steamid2`, `timestamp`) VALUES ";
		$req .= "(NULL, 'CAPITAL', '".(($row['price']*$row['amount'])/100*($items[$row['itemID']]['taxe']-1))."', '".$items[$row['itemID']]['job_id']."', 'achat HDV', 'SERVER', CURRENT_TIMESTAMP);";

		mysql_query($req);
		$req = "INSERT INTO `rp_users2` (`id`, `steamid`, `money`,`job_id`, `pseudo`, `steamid2`, `timestamp`) VALUES ";
		$req .= "(NULL, 'CAPITAL', '".(($row['price']*$row['amount'])/100*1)."', '211', 'achat HDV', 'SERVER', CURRENT_TIMESTAMP);";
		mysql_query($req);

		mysql_query("UNLOCK TABLES");


		mysql_query("UPDATE `rp_success` SET `hdv`=`hdv`+1 WHERE `SteamID`='".$row['steamid']."' AND `hdv`<>'-1';");
		mysql_query("UPDATE `rp_success` SET `hdv`='-1' WHERE `SteamID`='".$row['steamid']."' AND `hdv`>=10;");

		header("Location: index.php?page=hdv&action=idle");
		exit;
	}
}
else if( empty($_GET['action']) ) {
	header("Location: /index.php?page=hdv&action=idle");
	exit;
}

if(!empty($_GET['erreur']))
	$tpl->assign("ERR", getFAIL($_GET['erreur']));

$tpl->assign("argent", pretty_number($player['money']+$player['bank']));
$tpl->assign("ACTION", $_GET['action']);
draw($tpl->draw("page_hdv", $return_string=true), "L'Hotel des ventes" );

?>
