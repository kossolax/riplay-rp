<?php
	mysql_select_db("rp_csgo");
	$tpl = new raintpl();
        $g_szRankList = array(
                array(  "nom" => "Pr&eacute;sident",            "max" => 1),
                array(  "nom" => "Vice-Pr&eacute;sident",       "max" => 2),
                array(  "nom" => "Ministre",                    "max" => 4),
                array(  "nom" => "Haut Conseiller",             "max" => 6),
                array(  "nom" => "Assistant-Haut Conseiller",   "max" => 8),
                array(  "nom" => "Conseiller",                  "max" => 10),
                array(  "nom" => "Maire",                       "max" => 14),
                array(  "nom" => "Porte-Parole",                "max" => 16),
                array(  "nom" => "Citoyen d&eacute;vou&eacute;","max" => 18),
                array(  "nom" => "Citoyen",                     "max" => 21),
                array(  "nom" => "Habitant",                    "max" => 99999),
        );

	function GetRankDiff($pos, $diff) {
		if( $diff == 0 ) {
			return "<span class='label label-warning'>=</span>";
		}

		if( $pos > $diff ) {
			return "<span class='label label-danger'>-".($pos-$diff)."</span>";
		}
		if( $pos < $diff ) {
			return "<span class='label label-success'>+".($diff-$pos)."</span>";
		}

		return "<span class='label label-info'>=</span>";
	}
	function GetRank($pos, $point = 'notset' ) {
		global $g_szRankList;

		$amount = 0;
		foreach($g_szRankList as $value ) {

			if( $pos > $amount )
				$name = $value['nom'];

			$amount += $value['max'];
		}

		if( $point != 'notset' ) {
			if( intval($point) == 0 ) {
				return "Visiteur";
			}
			else if( intval($point) < 0 ) {
				return "R&ocirc;deur";
			}
		}

		return $name;
	}


	mysql_select_db("ts-x");
	$req = mysql_query("SELECT * FROM `srv_nicks`");
	while( $row = mysql_fetch_array($req) ) {
		$key = str_replace("STEAM_0", "STEAM_1", $row['steamid']);
		$nicks[ $key ] = $row['uname2'];
	}
	mysql_select_db("rp_csgo");

	if( isset($_GET['type']) )
		$type = mysql_real_escape_string($_GET['type']);
	else
		$type = "general";
		
	

	$limit = 100;
	switch( $type ) {
		case "pvp":
			$_PARSE['title'] = "PvP";
			break;
		case "sell":
			$_PARSE['title'] = "des ventes";
			break;
		case "buy":
			$_PARSE['title'] = "des achats";
			break;
		case "money_abc":
			$_PARSE['title'] = "des riches";
			break;
		case "zombie":
			$_PARSE['title'] = "Halloween";
			break;
		case "age":
			$_PARSE['title'] = "Ancienneté";
			$limit = 250;
			break;
		case "parrain":
			$_PARSE['title'] = "Parrainage";
			break;
		case "vital":
			$_PARSE['title'] = "Vitalit&eacute;";
			break;
		default:
			$_PARSE['title'] = "RP G&eacute;n&eacute;ral";
			$limit = 1000;
			break;
	}
	$tpl->assign("title", $_PARSE['title']);

	$query = mysql_query("SELECT * FROM `rp_rank` WHERE `type`='".$type."' ORDER BY rank ASC LIMIT ".$limit.";") or die(mysql_error());
	$i = 0; $array = array();
	while($row = mysql_fetch_array($query) ) {
		$data = "";
		$i++;

		if( $type == "general" ) {
			$last_rank = GetRank($row['rank'], $row['point']);

			if( !isset($row['rank']) )
				$row['rank'] = $i;
		}
		
		$array[$i] = $row;
		$array[$i]['diff'] = GetRankDiff($row['rank'], $row['old_rank']);
		$array[$i]['nick'] = utf8ToUnicodeEntities($nicks[$row['steamid']]);
		$array[$i]['rankstr'] = $last_rank;
	}
	$tpl->assign("rowData", $array);

	$query = mysql_query("SELECT * FROM `rp_rank` WHERE `type`='".$type."' AND `steamid`='".str_replace("STEAM_0", "STEAM_1", $user->data['steamid'])."';") or die(mysql_error());
	$i = 0; $array = array();
	if( $row = mysql_fetch_array($query) ) {
	       	$array = $row;
		$array['diff'] = GetRankDiff($row['rank'], $row['old_rank']);
		$array['nick'] = utf8ToUnicodeEntities($nicks[$row['steamid']]);
		if( $type == "general" )
			$array['rankstr'] = GetRank($row['rank'], $row['point']);
	}
	$tpl->assign("ownData", $array);

mysql_select_db("rp_csgo");
	$row = mysql_fetch_array(mysql_query("SELECT * FROM `rp_servers` WHERE `id`='1' LIMIT 1"));
	$_PARSE['date'] = strftime("%d/%m &agrave; %Hh%M:%Ss", $row['stats']);

	
	
	draw($tpl->draw("page_rank_rp", $return_string=true), "Classement RP");
?>
