<?php

define('GIVE_MONEY', 25000);
define('CUR_MONTH', 9);


if( $user->data['user_id'] == ANONYMOUS ) {
	if( isset($_GET['steamid']) ) {
		setcookie("steamid", $_GET['steamid'], time()+1000 );
		$_COOKIE["steamid"] = $_GET['steamid'];
	}

	if( isset($_COOKIE["steamid"]) ) {
		$user->data['steamid'] = mysql_real_escape_string($_COOKIE["steamid"]);
	}
	else {
	        error_box("Erreur", "Vous devez être connecté pour accèder à cette page.", "index.php");
		exit;
	}
}
include('forum/validate_steamid.php');
$tpl = new raintpl();

$SIMPLE = 0;
$r = @mysql_fetch_array(mysql_query("SELECT SUM(amount) FROM `ts-x`.`site_donations` WHERE `year`='17' AND month=".intval(date("n"))." AND `steamid`='".$user->data['steamid']."' LIMIT 1;"));
if( intval($r) >= 100 )
	$SIMPLE = 1;

if( $_GET['action'] == 'lastMonth' ) {
	$found = -1;
	$req = mysql_query("SELECT steamid,SUM(amount) as cpt, done FROM site_donations WHERE year=17 AND month=".(CUR_MONTH)." GROUP BY (steamid) ORDER BY cpt DESC LIMIT 10;");
	while($row = mysql_fetch_array($req) ) {
	        if( $row['done'] == 1 )
	                continue;
	        if( $row['steamid'] == $user->data['steamid'] ) {
			$found = $row['cpt'];
	        }
	}
	if( $found <= 0 ) {
		error_box("Erreur", "Vous n'&ecirc;tiez pas donateur le mois pr&eacute;c&eacute;dant, ou vous avez d&eacute;&agrave; obtenu votre cadeau.", "index.php?page=money");
		exit;
	}
	mysql_query("UPDATE `ts-x`.`site_donations` SET `done`='1' WHERE `steamid`='".$user->data['steamid']."' AND year=17 AND month=".(CUR_MONTH)."");
	mysql_query("INSERT INTO `rp_csgo`.`rp_users2` (`id`, `steamid`, `itemid`, `itemAmount`) VALUES (NULL, '".$user->data['steamid']."', '223', '".intval($found)."');");
	error_box("Envoy&eacute;", "Votre cadeau a &eacute;t&eacute; envoy&eacute;, merci &agrave; vous !", "index.php?page=money");
	exit;
}

function ValidateCode() {
	global $g_hBDD, $user;

	//Déclaration des variables
	$ident=$idp=$ids=$idd=$codes=$code1=$code2=$code3=$code4=$code5=$datas='';
	//On récupère les identifiants sous la forme "xxx;xxx;xxx"
	if(isset($_POST['idp'])) $idp = $_POST['idp'];
	if(isset($_POST['ids'])) $ids = $_POST['ids'];
	//$ids n'est plus utilisé, mais il faut conserver la variable pour une question de compatibilité
	if(isset($_POST['idd'])) $idd = $_POST['idd'];
	$ident=$idp.";".$ids.";".$idd;
	//On récupère le(s) code(s) sous la forme "xxxxxxxx;xxxxxxxx"
	if(isset($_POST['code1'])) $code1 = $_POST['code1'];
	if(isset($_POST['code2'])) $code2 = ";".$_POST['code2'];
	if(isset($_POST['code3'])) $code3 = ";".$_POST['code3'];
	if(isset($_POST['code4'])) $code4 = ";".$_POST['code4'];
	if(isset($_POST['code5'])) $code5 = ";".$_POST['code5'];
	$codes=$code1.$code2.$code3.$code4.$code5;
	//On récupère le champ DATAS"
	if(isset($_POST['DATAS'])) $datas = $_POST['DATAS'];
	//On encode les trois chaines en URL
	$ident=urlencode($ident);
	$codes=urlencode($codes);
	$datas=urlencode($datas);

	/* Envoie de la requête vers le serveur StarPass
	Dans la variable tab[0] on récupère la réponse du serveur
	Dans la variable tab[1] on récupère l'URL d'accès ou d'erreur suivant la réponse du serveur */
	$get_f=@file("http://script.starpass.fr/check_php.php?ident=$ident&codes=$codes&DATAS=$datas");
	if(!$get_f)
	{
		exit("Impossible de valider votre payement, les serveurs StarPass ne r&eacute;ponde pas.");
	}
	$tab = explode("|",$get_f[0]);

	if(!$tab[1]) $url = "https://www.ts-x.eu/index.php?page=money&error=1";
	else $url = $tab[1];

	// dans $pays on a le pays de l'offre. exemple "fr"
	$pays = $tab[2];
	// dans $palier on a le palier de l'offre. exemple "Plus A"
	$palier = urldecode($tab[3]);
	// dans $id_palier on a l'identifiant de l'offre
	$id_palier = urldecode($tab[4]);
	// dans $type on a le type de l'offre. exemple "sms", "audiotel, "cb", etc.
	$type = urldecode($tab[5]);
	// vous pouvez à tout moment consulter la liste des paliers à l'adresse : http://script.starpass.fr/palier.php

	//Si $tab[0] ne répond pas "OUI" l'accès est refusé
	//On redirige sur l'URL d'erreur
	if(substr($tab[0],0,3) != "OUI") {
		header("Location: $url");
		exit;
	}
	else {
		/* Le serveur a répondu "OUI"
			sinon on le renverra sur une page d'erreur */
		if( $codes == $user->data['donation_lastcode'] ) {
			$url = 'http://www.ts-x.eu/index.php?page=money&error=1&same=1';
			header("Location: $url");
	 		exit;
		}
		else {
			mysql_select_db("ts-x");

			$req = "UPDATE `phpbb3_users` SET ";
			$req .= "`donation_total`=`donation_total`+1, `donation_lasttime`='".time()."', `donation_lastcode`='".$codes."' ";
			$req .= "WHERE `user_id`='".$user->data['user_id']."' LIMIT 1;";
			mysql_query($req);

			$req = "INSERT INTO `site_donations` (`id`, `steamid`, `timestamp`, `month`, `year`, `code`)";
			$req .= " VALUES (NULL, '".$user->data['steamid']."', '".time()."', '".intval(date("n"))."', '".intval(date("y"))."','".$codes."');";
			mysql_query($req);

			$req = "INSERT INTO `rp_csgo`.`rp_users2` (`steamid`,`bank`) VALUES ('".$user->data['steamid']."',";
			$req .= " '".(GIVE_MONEY)*1.5."') ON DUPLICATE KEY UPDATE `bank`=`bank`+".(GIVE_MONEY)*1.5.";";
			mysql_query($req);

			$req = "UPDATE `rp_success` SET `made_donation`='-1' WHERE `SteamID`='".$user->data['steamid']."';";
			mysql_query($req);

			mysql_select_db("ts-x");

		}
	}
}

if( $_GET['paysafecard'] && $_POST && strlen($_POST['code']) > 12 ) {
	$to      = 'kossolax@ts-x.eu';
	$subject = '[PaySafeCard] '.$user->data['steamid'].'';
	$message = "Achat d'une paySafeCard de ".$_POST['amount']." pour ".$user->data['steamid']." .\r\n Le code de validation est: ".$_POST['code']."";
	$headers = "From: paysafecard@ts-x.eu\r\nReply-To: ".$user->data['user_email']."\r\n";

	mail($to, $subject, $message, $headers);
	error_box("Merci", "Merci de l'interet que vous avez envers nos serveurs! La somme vous sera revers&eacute;e sur votre compte RP dans les 12 heures maximum. Sachez toute fois, que cette validation prend généralement moins de 5 minutes" ,"index.php?page=money");
	exit;
}
if( $_GET['paid'] ) {
	ValidateCode();
	error_box("Merci", "Merci de l'interet que vous avez envers nos serveurs!" ,"index.php?page=money");
}
if( $_GET['same'] ) {
	error_box("Erreur", "Erreur: Ce code a déjà été validé.<br />","index.php?page=money");
	die();
}
else if( $_GET['error'] ) {
	error_box("Erreur", "Erreur: le code saisi est incorrect.<br />","index.php?page=money");
	die();
}
else if( $_GET['paypal_cancel'] ) {
        error_box("Erreur", "Erreur: Vous avez annuler la transaction PayPal.<br />","index.php?page=money");
        die();
}
else if( $_GET['paypal_done'] ) {
	error_box("Merci", "Merci de l'interet que vous avez envers nos serveurs! <br />La transaction est en cours de v&eacute;rification et sera valid&eacute;e sous peu.", "index.php?page=money");	exit;
}


mysql_query("UPDATE `rp_csgo`.`rp_users` SET `donateur`='0';");
mysql_query("UPDATE `ts-x`.`phpbb3_users` SET `donation_rank`='-1';");

$req = mysql_query("SELECT SUM(`amount`) AS `count`, D.`steamid`, `uname2` FROM `ts-x`.`site_donations`D INNER JOIN `ts-x`.`srv_nicks` N ON N.`steamid`=D.`steamid` WHERE `month`='".intval(date("n"))."' AND `year`='17' AND D.`steamid`<>'' AND `amount`<>0 GROUP BY D.`steamid` ORDER BY `count` DESC;");
$i = 0;
$last = 0;
$array = array();
while( $row = mysql_fetch_array($req) ) {
	$i++;
	$array[$i] = $row;
	if( $i <= 10 ) {
		mysql_query("UPDATE `rp_csgo`.`rp_users` SET `donateur`='".$i."' WHERE `steamid`='".str_replace("STEAM_0", "STEAM_1", $row['steamid'])."';");
		$last = $row['count'];
	}
	mysql_query("UPDATE `ts-x`.`phpbb3_users` SET `donation_rank`='".$i."' WHERE `steamid`='".$row['steamid']."';");
}
$objectif = mysql_fetch_array(mysql_query("SELECT SUM(amount) FROM site_donations WHERE year=17 AND month=".intval(date("n")).";"));
mysql_query("UPDATE `phpbb3_config` SET `config_value`='".$objectif[0]."' WHERE `config_name`='paid';");

	$tpl->assign("top10", $array);
	$tpl->assign("steamid", $user->data['steamid']);
	$tpl->assign("inTop10", round($last+0.01, 2));
	$tpl->assign("inTop10RP", round((($last+0.01)*10000), 2));
	$tpl->assign("objectif", $objectif[0]);

$req = mysql_query("SELECT steamid,SUM(amount) as cpt, done FROM site_donations WHERE year=17 AND month=".(CUR_MONTH)." GROUP BY (steamid) ORDER BY cpt DESC LIMIT 10;");
while($row = mysql_fetch_array($req) ) {
	if( $row['done'] == 1 )
		continue;
	if( $row['steamid'] == $user->data['steamid'] ) {
		$tpl->assign("lastMonth", true);
	}
}

if( !empty($user->data['partner']) && !empty($user->data['tokken']) )
  $tpl->assign("link", "https://steamcommunity.com/tradeoffer/new/?partner=".$user->data['partner']."&token=".$user->data['tokken']."");

$tpl->assign("simple", $SIMPLE);
draw($tpl->draw("page_don", $return_string=true), "Achat de $RP" );

?>
