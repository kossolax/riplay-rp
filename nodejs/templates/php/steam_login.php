<?php
function getRange() {
        return exec("whois ".$_SERVER['REMOTE_ADDR']." | grep inetnum | cut -d: -f2 | cut -d- -f1 | xargs");
}
$arrayBanRange = [
	"37.160.0.0"
];


if ($user->data['user_id'] == ANONYMOUS) {
        error_box("Vous devez être connecté pour valider votre SteamID", "index.php");
        exit;
}

require '/var/www/ts-x/includes/openid.php';

try {
	if(!isset($_GET['openid_mode'])) {
		$openid = new LightOpenID;
		$openid->identity = 'https://steamcommunity.com/openid/';
		header('Location: ' . $openid->authUrl());
	}
	else if($_GET['openid_mode'] == 'cancel') {
		header('Location: http://www.ts-x.eu/');
	}
	else {
		$openid = new LightOpenID;
		$openid->validate();

		$SteamID64 = str_replace("http://steamcommunity.com/openid/id/", "", $openid->identity);
		$SteamID = mysql_real_escape_string(SteamComIDToSteamID(mysql_real_escape_string($SteamID64)));

		include_once('/var/www/steamget/lib/__init_SteamGet__.php');

		$profile = SteamGet_Profile($SteamID64, true);
		$vpn = file_get_contents("http://check.getipintel.net/check.php?ip=".$_SERVER['REMOTE_ADDR']."&contact=kossolax@ts-x.eu&flags=f");
		$range = getRange();

		if( strstr($profile['privacyMessage'], "This user has not yet set up their Steam Community profile") || $profile['limited'] == "1" || floatval($vpn) >= 0.85 || in_array($range, $arrayBanRange) ) {
			error_box('Erreur', "Ce SteamID semble avoir été créer trop récement. Contactez un administrateur par mail: kossolax@ts-x.eu pour résoudre ce problème.");
			exit;
		}
		file_put_contents("/var/www/ts-x/cache/steam.txt", "".$user->data['user_id']."\t".$SteamID."\t".$_SERVER['REMOTE_ADDR']."\t".$range."\n", FILE_APPEND | LOCK_EX);

		mysql_query("UPDATE `phpbb3_users` SET `steamid`='".$SteamID."' WHERE `user_id`='".$user->data['user_id']."' LIMIT 1;");
		error_box("Succès", "Votre SteamID a été validé avec succès: ".$SteamID."");
		exit;
	}
} catch(ErrorException $e) {
	error_box('Erreur', "Une erreur de communication s'est produite, réessayer plus tard. Error: ".$e->getMessage()."");
	exit;
	//echo $e->getMessage();
}

?>
