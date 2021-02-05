<?php
	if( $_GET['action'] == 'report' ) {
                header("Location: https://www.ts-x.eu/index.php?page=roleplay2#/tribunal/report?".$_GET['steamid']);
                exit;
	}
	header("Location: https://www.ts-x.eu/index.php?page=roleplay2#/tribunal/rules");
	exit;

	$user->data['steamid'] = str_replace("STEAM_0", "STEAM_1", $user->data['steamid']);
	if( $_GET['action'] == 'post' ) {

		if( $_POST['report_steamid'] == '' || $_POST['report_steamid'] == ' ' ) {
			error_box("Erreur", "SteamID inconnu.", "index.php?page=tribunal&action=report");
			exit;
		}

		$steamid = mysql_real_escape_string($_POST['report_steamid']);
		$steamid = str_replace("STEAM_0", "STEAM_1", $steamid);

		if( strlen(trim($steamid)) != 0 ) {
			if( !preg_match("/^STEAM_[01]:[01]:[0-9]{5,12}$/", $steamid) ) {
				error_box("Erreur", "SteamID invalide.", "index.php?page=tribunal&action=report");
				exit;
			}
		}
		mysql_select_db("rp_csgo");

                $result = @mysql_fetch_array( mysql_query("SELECT * FROM `rp_users` WHERE `steamid`='".$steamid."' LIMIT 1"));
                if( !$result ) {
                        error_box("Erreur", "SteamID inconnu.", "index.php?page=tribunal&action=report");
                        exit;
                }
		mysql_select_db("ts-x");

		$result = @mysql_fetch_array(mysql_query("SELECT * FROM `site_report` WHERE (`own_steamid`='".mysql_real_escape_string($user->data['steamid'])."' OR `own_ip`='".mysql_real_escape_string($_SERVER['REMOTE_ADDR'])."') AND `timestamp`<='".(time()+(2*24*60*60))."' AND `report_steamid`='".mysql_real_escape_string($_POST['report_steamid'])."' LIMIT 1;"));

		if( $result ) {
			error_box("Erreur", "Il vous est impossible de raporter une fois de plus ce joueur si rapidement.", "index.php");
			exit;
		}

		$query = "INSERT INTO `site_report` (`id`, `own_steamid`, `own_ip`, `report_steamid`, `report_raison`, `report_date`, `report_moreinfo`, `timestamp`) VALUES ";
		$query .= "(NULL,
			'".mysql_real_escape_string($user->data['steamid'])."',
			'".mysql_real_escape_string($_SERVER['REMOTE_ADDR'])."',
			'".mysql_real_escape_string($_POST['report_steamid'])."',
			'".mysql_real_escape_string($_POST['reason'])."',
			'".mysql_real_escape_string($_POST['timestamp'])."',
			'".mysql_real_escape_string($_POST['moreinfo'])."',
			'".time()."');";
		mysql_query($query);

		error_box("Merci", "Merci d'avoir pris le temps de signaler cette personne!", "index.php");
		die();
	}
	else if( $_GET['action'] == 'case' ) {
		if( $user->data['user_id'] == ANONYMOUS && !isset($_GET['tokken']) ) {
		      error_box("Erreur", "Vous devez &ecrirc;tre connect&eacute; pour acc&egrave;der &agrave; cette page.", "index.php");
			exit;
		}
            if( $user->data['no_pyj'] == 0 && !isset($_GET['tokken']) ) {
                  error_box("Erreur", "D&eacute;sol&eacute;, seul les personnes poss&egrave;dant le rang: No-Pyj peuvent acc&egrave;der &agrave; cette page.", "index.php?page=tribunal&action=rules");
                  exit;
            }

		if( preg_match("/^STEAM_0:[01]:[0-9]{1,16}$/", $_GET['steamid']) ) {
			$_GET['steamid'] = str_replace("STEAM_0", "STEAM_1", $_GET['steamid']);
			header("Location: /index.php?page=tribunal&action=case&steamid=".$_GET['steamid']."");
			exit;
		}
		if( preg_match("/^STEAM_[01]:[01]:[0-9]{1,16}$/", $_GET['steamid']) ) {

			if( (group_memberships(19, $user->data['user_id'], true) || group_memberships(18, $user->data['user_id'], true) ) || $user->data['user_id'] == 6327 ) {
				$data[0] = uniqid();
				$data[1] = $_GET['steamid'];
				$data[2] = $user->data['steamid'];
				$data[3] = time();
				$forced = true;
			}
			else if( isset($_GET['tokken']) ) {

				$tokken = mysql_real_escape_string($_GET['tokken']);
				$steamid = mysql_real_escape_string($_GET['steamid']);
				if( strlen($tokken) < 20 ) {
					error_box("Erreur", "Tu n'as rien &agrave; faire ici. (Invalid tokken)","index.php?page=tribunal");
					exit;
				}
				if( strstr($steamid, "STEAM_1:") === false )
					mysql_select_db("rp_css");
				else
					mysql_select_db("rp_csgo");

				$bla = "SELECT * FROM `rp_tribunal` WHERE `steamid`='".$steamid."' AND `uniqID` LIKE '".substr($tokken, 0, 50)."%' LIMIT 1;";
				$valid = @mysql_fetch_array(@mysql_query($bla));
				if( $valid ) {
					if( ($valid['timestamp']+(15*60)) < time() ) {
						error_box("Erreur", "Le lien a expir&eacute;.","index.php?page=tribunal");
						exit;
					}
					$data[0] = uniqid();
					$data[1] = $_GET['steamid'];
					$data[2] = $user->data['steamid'] = 'notset';
					$data[3] = time();
					$forced = true;
				}
				else {
					error_box("Erreur", "Tu n'as rien &agrave; faire ici. (Invalid ID)<br /> ".$bla."","index.php?page=tribunal");
					exit;
				}
				mysql_select_db("ts-x");
			}
			else {
				$_SESSION['bypass'] = unserialize(decode($_COOKIE['bypass'], "pomme"));
				if( $_SESSION['bypass']['time']+(15*60) > time() && in_array($_GET['steamid'], $_SESSION['bypass']['data']) ) {
				
					$r = "SELECT COUNT(*) cpt FROM (";
					$r .= "    SELECT steamid";
					$r .= "		FROM `rp_csgo`.`rp_users`";
					$r .= "    	WHERE ( `job_id` IN (1,2,101,102) OR `refere` = 1) AND `steamid`='".$user->data['steamid']."'";
					$r .= "	UNION ALL";
					$r .= "	   SELECT `steamid`";
					$r .= "		FROM `rp_csgo`.`rp_users`";
					$r .= "		WHERE `job_id` IN (1,2,3,4,5,6,7,8,9,101,102,103,104,105,106,107,108,109) AND `steamid`='".$_GET['steamid']."'";
					$r .= "    ) AS data";
					$r .="    HAVING cpt=2";

					$r = mysql_query($r) or die(mysql_error());
					$r = @mysql_fetch_array($r);
	
					if( $r ) {
						$data[0] = uniqid();
						$data[1] = $_GET['steamid'];
						$data[2] = $user->data['steamid'];
						$data[3] = time();
						$forced = true;
					}
					else {
						die("Hacking attempt. N'est pas policier.");
					}
				}
				else {
                                        error_box("Erreur", "Tu n'as rien &agrave; faire ici. (no tokken)", "index.php?page=tribunal");
                                	exit;
                                }
			}
		}
		else {
	                $data = explode( ",", decode( $_GET['steamid'], "pwd_tribu"));
			$forced = false;
		}

		$data[2] = str_replace("STEAM_0", "STEAM_1", $data[2]);

                if( $data[2] != $user->data['steamid'] ) {
                        error_box("Erreur", "Une erreur s'est produite, votre connexion a &eacute;t&eacute; perdue lors du vote. (SteamID diff&eacute;rent)", "index.php?page=tribunal");
                        exit;
                }
                if( intval($data[3])+(1*60*60) < time() ) {
                        error_box("Erreur", "Une erreur s'est produite, votre connexion a &eacute;t&eacute; perdue lors du vote. (Temps de vote d&eacute;pass&eacute;)", "index.php?page=tribunal");
                        exit;
                }
		$steamid = $data[1];
		if( $steamid == "" ) {
			echo "<pre>";
			echo "\t Une erreur s'est produite, votre connexion a &eacute;t&eacute; perdue lors du vote. (SteamID inconnu).\n";
			echo "\t\t DEBUG:\n";
			print_r($data);
			exit;
			error_box("Erreur", "Une erreur s'est produite, votre connexion a &eacute;t&eacute; perdue lors du vote. (SteamID inconnu).", "index.php?page=tribunal&action=rules");
			exit;
		}

                $steamid64 = GetSteam_Convert_SteamID_SteamID64($steamid);

		$query = @mysql_fetch_array(mysql_query("SELECT * FROM `site_report` WHERE `report_steamid`='".$steamid."' LIMIT 1;"));
		if( !$query && !$forced) {
			error_box("Erreur", "Une erreur s'est produite, votre connexion a &eacute;t&eacute; perdue lors du vote. (SteamID inconnu).", "index.php?page=tribunal&action=rules");
			exit;
		}
		if( strstr($steamid, "STEAM_1:") === false )
			mysql_select_db("rp_css");
		else
			mysql_select_db("rp_csgo");

		$query = @mysql_fetch_array(mysql_query("SELECT * FROM `rp_users` LEFT JOIN `rp_jobs` ON `rp_users`.`job_id`=`rp_jobs`.`job_id` WHERE `steamid`='".$steamid."' LIMIT 1;"));
		mysql_select_db("ts-x");
		
		$tpl = new raintpl();
		

		$profile = SteamGet_Profile($steamid64);
		if( isset($tokken) ) {
			$_GET['date'] = date("d/m/Y");
			$data = GetTribunalLog($steamid/*, $_GET['date']*/);
		}
		else if( $_GET['ajax'] == 1 && isset($_GET['date']) ) {
			$data = GetTribunalLog($steamid, $_GET['date']);
		}
		else {
			$data = GetTribunalLog($steamid);
		}
		
		$tpl->assign("steamid", $steamid);
		$tpl->assign("steamid64", $steamid64);
		$tpl->assign("nom", utf8ToUnicodeEntities(utf8_decode($profile['Nom'])));
		$tpl->assign("job", $query["job_name"]);
		$tpl->assign("money", $query['money']+$query['bank']);

		$data['list_say'] = array_reverse($data['list_say']);
		$data['list_money'] = array_reverse($data['list_money']);
		$data['list_dead'] = array_reverse($data['list_dead']);
		$data['list_jail'] = array_reverse($data['list_jail']);
		$data['list_item'] = array_reverse($data['list_item']);
		$data['list_vendre'] = array_reverse($data['list_vendre']);
		$data['list_vol'] = array_reverse($data['list_vol']);
		$data['list_connect'] = array_reverse($data['list_connect']);
		$data['list_admin'] = array_reverse($data['list_admin']);
		

		$data['time_played'] = round($data['time_played']/(60*60), 1);	
		$tpl->assign("case", $data);
		$tpl->assign("steamid_encoded", encode( "".uniqid().",".$steamid.",".$user->data['steamid'].",".time()."" , "pwd_tribu"));


		$reqPyj = @mysql_fetch_array(@mysql_query("SELECT `no_pyj` FROM  `phpbb3_users` WHERE `steamid`='".str_replace("STEAM_1", "STEAM_0", $steamid)."' LIMIT 1;"));
		if( isset($reqPyj) && $reqPyj['no_pyj'] == 1 )
			$tpl->assign("nopyj", true);
		
		
		

		if( $_GET['ajax'] == 1 && isset($_GET['date']) ) {
			die(json_encode($data));
		}

		$_PARSE['subpage'] = parsetemplate(gettemplate('page_tribunal_case'), $_PARSER);
		
		
		draw($tpl->draw("page_tribunal_case", $return_string=true), "Tribunal" );
		exit;

	}
	else if( $_GET['action'] == 'vote' ) {
		$data = explode( ",", decode( $_POST['steamid'], "pwd_tribu"));
                $data[2] = str_replace("STEAM_0", "STEAM_1", $data[2]);

		if( $user->data['steamid'] == 'notset' || $user->data['steamid'] == 1 ) {
			echo "<script type='text/javascript'>window.close();</script>";
			exit;
		}

		if( $data[2] != $user->data['steamid'] ) {
			error_box("Erreur", "Une erreur s'est produite, votre connexion a &eacute;t&eacute; perdue lors du vote. (SteamID diff&eacute;rent)", "index.php?page=tribunal");
			exit;
		}
		if( intval($data[3])+(1*60*60) < time() ) {
			error_box("Erreur", "Une erreur s'est produite, votre connexion a &eacute;t&eacute; perdue lors du vote. (Temps de vote d&eacute;pass&eacute;)", "index.php?page=tribunal");
			exit;
		}
		if( intval($data[3])+(15) > time() && $_POST['value'] != 2 ) {
			error_box("Erreur", "Une erreur s'est produite, votre connexion a &eacute;t&eacute; perdue lors du vote. (Temps de vote trop cours... TRICHEUR)", "index.php?page=tribunal");
			exit;
		}

		$steamid = $data[1];
		$value = intval($_POST['value']);

		$mysql = @mysql_fetch_array( mysql_query("SELECT * FROM `site_tribunal` WHERE `own_steamid`='".$user->data['steamid']."' AND `report_steamid`='".$steamid."' LIMIT 1;") );
		if( $mysql ) {
			error_box("Erreur", "Vous avez d&eacute;j&agrave; vot&eacute; pour cette personne.", "index.php?page=tribunal");
			exit;
		}


		mysql_query("INSERT INTO `site_tribunal` (`id`, `own_steamid`, `report_steamid`, `vote`) VALUES (NULL, '".$user->data['steamid']."', '".$steamid."', '".$value."');");
		error_box("Merci!", "Votre jugement a bien &eacute;t&eacute; pris en compte, et nous vous en remercions.", "index.php?page=tribunal&action=rules");
		exit;
	}
	else if( $_GET['action'] == 'start' ) {
		if( $user->data['no_pyj'] == 0 ) {
			error_box("Erreur", "D&eacute;sol&eacute;, seul les personnes poss&egrave;dant le rang: No-Pyj peuvent acc&egrave;der &agrave; cette page.", "index.php?page=tribunal&action=rules");
			exit;
		}

		$mysql = mysql_query("SELECT * FROM `site_report` WHERE `report_steamid`<>'".$user->data['steamid']."' AND `own_steamid`<>'".$user->data['steamid']."' ORDER BY `id` DESC;");
	        $report = array();
	        while( $row = mysql_fetch_array($mysql) ) {
	                $report[ $row['report_steamid'] ] = 1;
	        }

		$mysql = mysql_query("SELECT * FROM `site_tribunal` WHERE `own_steamid`='".$user->data['steamid']."';");
		$tribunal = array();
		while( $row2 = mysql_fetch_array($mysql) ) {
			$tribunal[ $row2['report_steamid'] ] = 1;
		}

		foreach( $report as $key => $value ) {
			if( isset($tribunal[$key]) && $tribunal[$key] == 1 )
				continue;

			header("Location: /index.php?page=tribunal&action=case&steamid=".encode("".uniqid().",".$key.",".$user->data['steamid'].",".time()."", "pwd_tribu")."");
			exit;
		}
		error_box("Erreur", "Il n'y a plus aucun cas a traiter, merci &agrave; vous!", "index.php?page=tribunal&action=rules");
		exit;
	}
	else if( $_GET['action'] == 'rules' || !isset($_GET['action']) ) {
		$tpl = new raintpl();
		draw($tpl->draw("page_tribunal_rules", $return_string=true), "Tribunal", array("bootstrap-datetimepicker.min.js") );
		exit;
	}
	else if( $_GET['action'] == 'report' ) {
		header("Location: https://www.ts-x.eu/index.php?page=roleplay2#/tribunal/report?".$_GET['steamid']);
		exit;
		$tpl = new raintpl();
		$tpl->assign("steamid", $_GET['steamid']);
		$tpl->assign("timestamp", prettytime(time()));
		
		draw($tpl->draw("page_tribunal_report", $return_string=true), "Tribunal" );
		exit;
	}
	
?>
