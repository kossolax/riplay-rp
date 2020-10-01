<?php

function getAge($birthday) {
	$now = getdate();
	list($bday_day, $bday_month, $bday_year) = array_map('intval', explode('-', $birthday));
	if ($bday_year) {
		$diff = $now['mon'] - $bday_month;

		if ($diff == 0) {
			$diff = ($now['mday'] - $bday_day < 0) ? 1 : 0;
		}
		else {
			$diff = ($diff < 0) ? 1 : 0;
		}

		return (int) ($now['year'] - $bday_year - $diff);
	}
	return 0;
}

$sub = "index";
if( isset($_GET['sub']) )
	$sub = preg_replace('/[^A-Za-z0-9]/', '', $_GET['sub']);

if( !file_exists("/var/www/ts-x/templates/tpl/aide/".$sub.".tpl") ) {
	header("Location: /index.php?page=fail&erreur=404");
	exit;
}

$steamid = str_replace("STEAM_0", "STEAM_1", $user->data['steamid']);

if( $user->data['user_id'] == ANONYMOUS )
	$steamid = "inconnu";

$query = "SELECT * FROM `rp_csgo`.`rp_users` U INNER JOIN `rp_csgo`.`rp_jobs` J ON J.`job_id`=U.`job_id` INNER JOIN `rp_csgo`.`rp_groups` G ON G.`id`=U.`group_id` WHERE `steamid`='".$steamid."' LIMIT 1;";
$myself = mysql_fetch_array( mysql_query( $query ) );

$tpl = new raintpl();
$tpl->assign("nopyj", $user->data['no_pyj']);
$tpl->assign("name", $user->data['username']);
$tpl->assign("steamid", $steamid);
$tpl->assign("money", $myself['money']+$myself['bank']);
$tpl->assign("job", $myself['job_name']);
$tpl->assign("gang", $myself['name']);
$tpl->assign("age", getAge($user->data['user_birthday']));
$tpl->assign("xp", $myself['xp']);

$page = $tpl->draw("aide/header", $return_string=true);
$page .= $tpl->draw("aide/".$sub, $return_string=true);
$page .= $tpl->draw("aide/footer", $return_string=true);

draw( $page, "Aide" );

?>
