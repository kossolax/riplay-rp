<?php

//	require_once '/var/www/ts-x/includes/htmlpurifier-4.2.0-standalone/HTMLPurifier.standalone.php';
//	$purifier_cfg = HTMLPurifier_Config::createDefault();
//	$purifier_cfg->set('Core.Encoding', 'ISO-8859-1');
//	$purifier = new HTMLPurifier($purifier_cfg);

	$mail = strtolower(IRCsafty($user->data['username_clean']));

	if( isset($_GET['email']) ) {
		if( group_memberships(19, $user->data['user_id'], true) || group_memberships(18, $user->data['user_id'], true) ) {

			$data = explode( ",", decode( $_GET['email'], "safe_".$user->data['steamid'].""));

			if( $data[2] != $user->data['steamid'] ) {
				exit;
			}
			$mail = strtolower(IRCsafty($data[1]));;
		}
	}

	$spam = mysql_query("SELECT `from` FROM `mail_spam` WHERE LOWER(`to`)='".mysql_real_escape_string($mail)."@ts-x.eu';");
	while( $row = mysql_fetch_array($spam) ) {
		mysql_query("DELETE FROM `mail_system` WHERE LOWER(`from`)='".strtolower($row['from'])."' AND LOWER(`to`)='".mysql_real_escape_string($mail)."@ts-x.eu';");
	}

	if( $_GET['action'] == 'send' ) {

		display( parsetemplate( gettemplate('page_mail_write'), $_PARSE), 'eMail', 'eMail', 'location_admin');
		exit;
	}
	else if( $_GET['action'] == 'sent' ) {
		$header = "From: \"".$mail."\" <".$mail."@ts-x.eu>\n";
		$header .='Content-Type: text/html; charset="iso-8859-1"'."\n";
		$header .='Content-Transfer-Encoding: 8bit';
		$sent = mail($_POST['email'], $_POST['subject'], $_POST['message'], $header);
		error_box("Envoyé", "Votre mail a été envoyé avec succès à l'adresse: ".$_POST['email']."", "admin.php?page=email");
		exit;
	}

	if( $_GET['action'] == 'delete' ) {
		if( $mail == "contact" )
			exit;

		if( isset($_GET['messageid']) && intval($_GET['messageid']) > 0 ) {
			mysql_query("DELETE FROM `mail_system` WHERE `id`='".mysql_real_escape_string($_GET['messageid'])."' AND LOWER(`to`)='".mysql_real_escape_string($mail)."@ts-x.eu' LIMIT 1;");
		}
	}
	else if( $_GET['action'] == 'spam' ) {
		if(  $mail == "contact" )
			exit;

		if( isset($_GET['messageid']) && intval($_GET['messageid']) > 0 ) {
			$row = mysql_fetch_array(mysql_query("SELECT `from` FROM `mail_system` WHERE `id`='".mysql_real_escape_string($_GET['messageid'])."' AND LOWER(`to`)='".mysql_real_escape_string($mail)."@ts-x.eu' LIMIT 1;"));
			mysql_query("INSERT INTO `ts-x`.`mail_spam` (`id`, `to`, `from`) VALUES (NULL, '".mysql_real_escape_string($mail)."@ts-x.eu', '".$row['from']."');");
		}
		$spam = mysql_query("SELECT `from` FROM `mail_spam` WHERE LOWER(`to`)='".mysql_real_escape_string($mail)."@ts-x.eu';");
        	while( $row = mysql_fetch_array($spam) ) {
        	        mysql_query("DELETE FROM `mail_system` WHERE LOWER(`from`)='".strtolower($row['from'])."' AND LOWER(`to`)='".mysql_real_escape_string($mail)."@ts-x.eu';");
        	}
	}
	else {
		if( isset($_GET['messageid']) && intval($_GET['messageid']) > 0 ) {

			$query = mysql_query("SELECT * FROM `mail_system` WHERE `id`='".mysql_real_escape_string($_GET['messageid'])."' AND LOWER(`to`)='".mysql_real_escape_string($mail)."@ts-x.eu' LIMIT 1;");
			while( $row = mysql_fetch_array($query) ) {

				$from = explode('@', $row['from']);

				$_PARSE['Title'] = '<table width="100%" border="0" cellspacing="0" cellspading="0" style="border-bottom:3px groove #ccc;">';
				$_PARSE['Title'] .= '<tr><td style="font-size:18px;"><img src="images/icons/delete.gif" onclick="ReadEmail(\''.$mail.'\', '.$row['id'].', 1); return false;" style="cursor:pointer;"/>'.utf8_encode($row['subject']).'</td>';
				$_PARSE['Title'] .= '<td style="width:350px;text-align:right; style="font-size:12px;">Par <a href="mailto:'.$row['from'].'">'.$from[0].'</a> - '.prettytime($row['timestamp']).'</td></tr></table>';

				$_PARSE['row_mail_list'] = utf8_encode($row['message']);

				$_PARSE['EndBottom'] = '<table width="100%" border="0" cellspacing="0" cellspading="0" style="border-bottom:3px groove #ccc;">';
				$_PARSE['EndBottom'] .= '<tr><td style="text-align:center;"><a href="#" onclick="ReadEmail(\''.$mail.'\', '.$row['id'].', 1); return false;" style="cursor:pointer;">Supprimer</a></td><td onclick="ReadEmail(\''.$mail.'\', 0, 0); return false;" style="cursor:pointer;">Retour à la liste des messages</td></tr></table>';
				die( PreFormatedParsing(parsetemplate( gettemplate('page_mail'), $_PARSE)));
			}
		}
	}

	$count = 0;
	$row_tpl = "<table width='100%' ><tr>  <td style='width:40px;'>Sup.</td>   <td style='width:150px;'>Reçu de:</td>       <td style='width:auto;'>Sujet</td> <td style='width:20px;'>Spam</td></tr>";

	$query = @mysql_query("SELECT * FROM `mail_system` WHERE LOWER(`to`)='".mysql_real_escape_string($mail)."@ts-x.eu' ORDER BY `timestamp` DESC;");
	while( $row = @mysql_fetch_array($query) ) {
		$count++;
		$from = explode('@', $row['from']);

		$row_tpl .= "<tr>";
		$row_tpl .= "<td><img src=\"images/icons/delete.gif\" onclick=\"ReadEmail('".$mail."', ".$row['id'].", 1); return false;\" style=\"cursor:pointer;\"/></td>";
		$row_tpl .= "<td onclick=\"ReadEmail('".$mail."', ".$row['id'].", 0); return false;\" style=\"cursor:pointer;\">".$from[0]."</td>";
		$row_tpl .= "<td onclick=\"ReadEmail('".$mail."', ".$row['id'].", 0); return false;\" style=\"cursor:pointer;\">".utf8_encode($row['subject'])."</td>";
		$row_tpl .= "<td><img src=\"/images/icons/poubelle.png\" onclick=\"MarkSpam('".$mail."', ".$row['id'].", '".$row['from']."'); return false;\" style=\"cursor:pointer;\"/></td>";
		$row_tpl .= "</tr>";
	}

	if( $count > 0 ) {
		$row_tpl .= "</table>";
	}
	else {
		$row_tpl = "<center>Il n'y a pas de mail à lire.</center>";
	}

	$_PARSE['Title'] = '<table width="100%" border="0" cellspacing="0" cellspading="0" style="border-bottom:3px groove #ccc;">';
	$_PARSE['Title'] .= '<tr><td><span style="font-size:20px; font-weight:bold; font-family: "Century Gothic",Arial,Helvetica,sans-serif; font-style:italic;">Liste des emails reçu pour '.$mail.'@ts-x.eu:</span></td><td style="text-align:right;"><a href="admin.php?page=email&action=send">Envoyer un eMail</a></td></tr></table>';

	$_PARSE['EndBottom'] = '';

	$_PARSE['user_mail'] = $mail;
	$_PARSE['row_mail_list'] = $row_tpl;

	if( intval($_GET['ajax']) == 1 ) {
		die( PreFormatedParsing(parsetemplate( gettemplate('page_mail'), $_PARSE) ));
	}
	else {
		display( parsetemplate( gettemplate('page_mail'), $_PARSE), 'eMail', 'eMail', 'location_admin');
	}
?>

