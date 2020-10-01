<?php
if( $_GET['action'] == 'join_group' ) {
	mysql_query("UPDATE `phpbb3_users` SET `join_date`='".time()."' WHERE `steamid`='".$user->data['steamid']."';");
	header("Location: http://steamcommunity.com/groups/CSS_RP");
	exit;
}


	if( isset($_GET['link']) && ($_GET['link'] != "http://steamcommunity.com/") ) {
		$link = $_GET['link'];
		$link = str_replace("/home/","",$link);
		$return = GetSteamPseudo($link);

		$id = $return['id'];
		$pseudo = $return['nick'];

		if($id == -1 || $pseudo == "-1") {
			error_box("Erreur", "La page Steam indiquée est invalide.", "index.php?page=steam");
			exit;
		}

		$data .= "<table width='100%'><tr><td>SteamID:</td><td>Pseudo sur Steam:</td></tr><tr><td>".SteamComIDToSteamID($id)."</td><td>".($pseudo)."</td></tr></table>";
		error_box("Succès", $data, "index.php?page=steam");
		exit;
	}
	else if( isset($_GET['steamid']) && ($_GET['steamid'] != "STEAM_0:") ){
		$profil = GetFriendID($_GET['steamid']);
		$link = "http://steamcommunity.com/profiles/".$profil."/";
		$return = GetSteamPseudo($link);

		$id = $return['id'];
		$pseudo = $return['nick'];

		if( $profil == "0" ) {
			error_box("Erreur", "Le SteamID indiqué est invalide.", "index.php?page=steam");
			exit;
		}

		$data .= "<table width='100%'><tr><td>SteamID:</td><td>Pseudo sur Steam:</td></tr><tr><td><a href='".$link."'>".$_GET['steamid']."</a></td><td>".($pseudo)."</td></tr></table>";
		error_box("Succès", $data, "index.php?page=steam");
		exit;
	}
	
	
	$tpl = new raintpl();
	draw($tpl->draw("page_steam", $return_string=true), "roleplay");
?>
