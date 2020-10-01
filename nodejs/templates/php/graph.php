<?php
	$_PARSE['data'] = '[';


	if( $_GET['type'] == 'machine' ) {
		$sql = "SELECT `job_id`, COUNT(*) mnt FROM `rp_csgo`.`rp_sell` WHERE `item_type` = '2' AND `timestamp`>'".(time()-(7*24*60*60))."'GROUP BY `job_id` ORDER BY `mnt` DESC;";
		$mysql = mysql_query($sql);
		while( $row = mysql_fetch_array($mysql) ) {
			$_PARSE['data'] .= "{ label: \"".pretty_job($row['job_id'])."\", data: ".$row['mnt']."},";
		}

		$_PARSE['titre'] = "machines à faux-billet";
	}
	else if( $_GET['type'] == 'vente' ) {
		$query = "SELECT S.`job_id`, SUM(S.`amount`*(I.`prix`)) as  mnt";
		$query .= "	FROM `rp_csgo`.`rp_sell` S INNER JOIN `rp_csgo`.`rp_items` I ON I.`job_id`=`S`.`job_id`";
		$query .= "	WHERE `item_type` = '0'  AND `timestamp`>'".(time()-(7*24*60*60))."' AND `steamid` LIKE 'STEAM_%' AND ( S.job_id=141 OR S.job_id>=200 OR 1) GROUP BY S.`job_id` ORDER BY `mnt` DESC LIMIT 0,50;";

		$mysql = mysql_query($query) or die(mysql_error());
                while( $row = mysql_fetch_array($mysql) ) {
                        $_PARSE['data'] .= "{ label: \"".pretty_job($row['job_id'])."\", data: ".$row['mnt']."},";
                }

                $_PARSE['titre'] = "ventes du serveur";
        }
	else {
		exit;
	}
	$_PARSE['data'] = rtrim($_PARSE['data'], ",");
	$_PARSE['data'] .= "]";

	display( parsetemplate( gettemplate('page_graph'), $_PARSE), 'Graph', 'Graph', 'location_roleplay');
?>
