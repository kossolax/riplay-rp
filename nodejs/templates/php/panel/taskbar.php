<?php

	$txt .= '<br />';
	$txt .= '<br /><br /><br />';
	$txt .= '<br /><br /><br />';

	$txt .= "<div class='TaskBarButton'>eMail:</div>";

	$to_read = array();
	$to_read[] = strtolower(IRCsafty($user->data['username_clean']));

	if( group_memberships(68, $user->data['user_id'], true) ) {
		$to_read[] = "staff";
	}
	if( $user->data['user_id'] == 2 || $user->data['user_id'] == 6440 || $user->data['user_id'] == 4164 ||
	 $user->data['user_id'] == 6727 || $user->data['user_id'] == 1592 ||  $user->data['user_id'] == 11272 || $user->data['user_id'] == 3232
	) {
		$to_read[] = "police";
		$to_read[] = "admin";
	}

	$to_read[] = "contact";

	$txt .= "<table width='145'>";
	foreach( $to_read as $key => $value) {

		$result = mysql_fetch_array( mysql_query(("SELECT COUNT(`id`) FROM `mail_system` WHERE LOWER(`to`)='".$value."@ts-x.eu'; "));

		$link = encode( "".uniqid().",".$value.",".$user->data['steamid']."" , "safe_".$user->data['steamid']."");
		$txt .= '<tr>';

		if( $result[0] > 0 ) {
			$txt .= '<td width="16"><img src="/images/icons/email_unread.gif"></td>';
		}
		else {
			$txt .= '<td width="16"><img src="/images/icons/email.gif"></td>';
		}
		$txt .= '<td style="vertical-align:top;"><a href="http://www.ts-x.eu/panel.php?old=1&page=email&email='.$link.'">'.$value.'@ts-x.eu</a></td>';
		$txt .= '<td style="vertical-align:top; width:20px;">'.$result[0].'</td>';

		$txt .= '</tr>';
	}
	$txt .= '</table>';
	$txt .= '<br />';

	$txt .= "<div class='TaskBarButton'>Serveurs:</div>";
        $query = mysql_query(("SELECT * FROM `adm_serv` ORDER BY `port` ASC");
        while( $row = mysql_fetch_array($query) ) {

		if( $row['is_on'] == 1 ) {
			$txt .= "<span style='color:green;'>&#x25CF;</span>";
		}
		else {
			$txt .= "<span style='color:red;'>&#x25CF;</span>";
		}

		if( $row['lastcheck'] < (time()-60) ) {
	                infoServ(''.$row['ip'].'',  intval($row['port']), $info, 'cssource');

	                if( !isset($info['map']) ) {
				$row['is_on'] = 0;
				$row['num_players'] = 0;
	                }
			else {
				$row['is_on'] = 1;
			}
			mysql_query(("UPDATE `adm_serv` SET `is_on`='".$row['is_on']."',`lastcheck`='".time()."',`current`='".$info['num_players']."' WHERE `uniq_id` = '".$row['uniq_id']."' LIMIT 1;");

		}

		$txt .= "<a href='http://www.ts-x.eu/panel.php?page=infoserv&serv=".$row['uniq_id']."'>".$row['uniq_id']."</a><br />";

        }

	$txt .= '<br />';

	$txt .= "<div class='TaskBarButton'>Liens:</div>";
	$txt .= "<ul>";
	$txt .= "<li><a href='http://www.ts-x.eu/phpmyadmin/'>PhpMyAdmin</a></li>";
	$txt .= "<li><a href='http://www.ts-x.eu/sourcetv/'>SourceTV</a></li>";
	$txt .= "<li><a href='http://www.ts-x.eu/logs/'>errorLog</a></li>";
	$txt .= "<li><a href='http://www.ts-x.eu/nopyj/'>No-Pyj</a></li>";


	$txt .= "</ul>";

	$txt .= '<br />Charge: <br />';
	$txt .= '<img src="/bar/loadavg.png" width="145" />';
	$txt .= '<br />CPU: <br />';
        $txt .= '<img src="/bar/cpu.png" width="145" />';

	$txt .= '<br /><br /><br />';

	$txt .= prettytime(time());

	die($txt);

?>

