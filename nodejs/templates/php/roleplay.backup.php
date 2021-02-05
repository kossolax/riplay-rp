<?php

$dbN = "`rp_csgo`.";
$_GET['game'] = "csgo";
$user->data['steamid'] = str_replace("STEAM_0", "STEAM_1", $user->data['steamid']);

	function GetRank($pos, $point = 'notset' ) {
		$g_szRankList = array(
			array(  "nom" => "Pr&eacute;sident",            		"max" => 1),
			array(  "nom" => "Vice-Pr&eacute;sident",		"max" => 2),
			array(  "nom" => "Ministre",						"max" => 4),
			array(  "nom" => "Haut Conseiller",				"max" => 6),
			array(  "nom" => "Assistant-Haut Conseiller",		"max" => 8),
			array(  "nom" => "Conseiller",					"max" => 10),
			array(  "nom" => "Maire",						"max" => 14),
			array(  "nom" => "Porte-Parole",					"max" => 16),
			array(  "nom" => "Citoyen d&eacute;vou&eacute;","max" => 18),
			array(  "nom" => "Citoyen",						"max" => 21),
			array(  "nom" => "Habitant",						"max" => 99999),
		);
		
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
	function g2b($id) {
		global $g_szGROUPS;
		if( $id == 0 )
			return 0;
		if( $g_szGROUPS[$id]['is_chef'] )
			return $id;
		return $g_szGROUPS[$id]['owner'];
	}
	function b2g($jobid) {
		$i = -9;
		while($jobid>0) {
			$i += 10;
			$jobid--;
		}
		$jobid = $i;
		return $jobid;
	}
	
	if( $_GET['sub'] == 'signature' ) {

		$steamid = mysql_real_escape_string($_GET['steamid']);
		if( strstr($steamid, "STEAM_1:") !== false ) {
			$dbN = "`rp_csgo`.";
		}

		$cache = "cache/sign/".$_GET['type']."-".$steamid.".jpg";
		$expire = time() + 300;

		header('Content-Type: image/jpeg');
		header('Cache-Control: public');
	        header('Expires: '.gmdate('D, d M Y H:i:s \G\M\T', time() + (7 * 24 * 60 * 60)));
	        header('Last-Modified: '.gmdate('D, d M Y H:i:s \G\M\T', time() + (7 * 24 * 60 * 60)));
		if(file_exists($cache) && filemtime($cache) > $expire ) {
			readfile($cache);
		}
		else {

			$query = "SELECT * ,  `rp_groups`.`name` AS  `group_name`, `rp_users`.`name` AS `name`";
			$query .= "	FROM  ".$dbN."`rp_users` ";
			$query .= "	LEFT JOIN  ".$dbN."`rp_jobs` ON  `rp_users`.`job_id` =  `rp_jobs`.`job_id` ";
			$query .= "	LEFT JOIN  ".$dbN."`rp_groups` ON  `rp_users`.`group_id` =  `rp_groups`.`id` ";
			$query .= "     LEFT JOIN  ".$dbN."`rp_rank` ON  `rp_users`.`steamid` =  `rp_rank`.`steamid` ";
			$query .= "	LEFT JOIN  ".$dbN."`rp_idcard` ON  `rp_users`.`steamid` =  `rp_idcard`.`steamid` ";
			$query .= "	WHERE  `rp_users`.`steamid` =  '".$steamid."' AND `rp_rank`.`type`='general'";

			$req = mysql_query($query) or die(mysql_error());
			$req = mysql_fetch_array($req);
			ob_start();

			if( $_GET['type'] == 'job' ) {
				$jobid = ceil($req['job_id']/10.0);
			}
			else if( $_GET['type'] == 'group' ) {
				$jobid = ceil($req['group_id']/10.0);
			}

			$i = -9;
			while($jobid>0) {
				$i += 10;
				$jobid--;
			}
			$jobid = $i;


			$path = "/var/www/ts-x/images/roleplay/".$_GET['type']."/".$jobid.".jpg";
			$img = imagecreatetruecolor(800, 200);
			$img2 = @imagecreatefromjpeg($path);
			@list($width, $height) = getimagesize($path);
			@imagecopyresampled($img, $img2, 0, 0, 0, 0, 800, 200, $width, $height);

			$black = imagecolorallocate($img, 0, 0, 0);
			$white = imagecolorallocate($img, 255, 255, 255);
			$alpha = imagecolorallocatealpha($img, 0, 0, 0, 60);
			$police = "/var/www/ts-x/fonts/tahoma.ttf";

			imagefilledrectangle($img, 50, 20, 580, 180, $alpha);
			imagerectangle($img, 50, 20, 580, 180, $black);
			imagerectangle($img, 0, 0, 799, 199, $black);

			function write($x, $y, $text, $size=15) {
				global $black, $white, $img, $police;

				imagettftext( $img, $size, 0.0, $x+1, $y+1, $black, $police, $text);
				imagettftext( $img, $size, 0.0, $x, $y, $white, $police, $text);

			}

			$y = 60;
			write(80, $y, "Pseudo:");
			write(160, $y, $req['name']);
			$y += 25;
			write(80, $y, "Job:");
			write(160, $y, $req['job_name']);

			if( $req['group_id'] != 0 ) {
				$y += 25;
				write(80, $y, "Groupe: ");
				write(160, $y, $req['group_name']);
			}

			if( $req['rank'] != 0 ) {
				$y += 25;
				write(80, $y, "Rang: ");
				write(160, $y, GetRank($req['rank'], $req['point'])." (pos. ".$req['rank'].")");
				$y += 25;
			}

			write(80, $y, "Age: ");
			write(160, $y, pretty_date($req['played']*600));

			write(608, 185, "178.32.42.113:27015");
			write(695, 196, prettytime(time()), 6);


			imagejpeg($img, NULL, 100);
			imagedestroy($img);

			$page = ob_get_contents();
			ob_end_clean();

			file_put_contents($cache, $page);
			echo $page;
		}
		
		exit;
	}
	if( $_GET['sub'] == 'CAPITAL' ) {
		$_PARSE['graph'] = display_job_info(-1, "CAPITAL", 0, $dbN);
		display( parsetemplate( gettemplate('roleplay_capital'), $_PARSE), 'RolePlay', 'RolePlay', 'location_server');
		exit;
	}
	if( $_GET['sub'] == 'MACHINE' ) {
                $_PARSE['graph'] = display_job_info(-1, "MACHINE", 0, $dbN);
                display( parsetemplate( gettemplate('roleplay_capital'), $_PARSE), 'RolePlay', 'RolePlay', 'location_server');
                exit;
        }

	if( $_GET['sub'] != 'job' && $_GET['sub'] != 'group' ) {
		if( $_POST ) {
			if( $_GET['type'] == 'group' ) {

				$myself = mysql_fetch_array( mysql_query("SELECT * FROM ".$dbN."`rp_users` WHERE `steamid`='".$user->data['steamid']."' LIMIT 1;"));
				if( $myself['group_id'] <= 0 ) {
					error_box("Erreur", "Vous n'êtes dans aucun groupe.", "/index.php?page=roleplay&game=".$_GET['game']."");
					exit;
				}

				$steamid = $user->data['steamid'];
				$grade = 0;

				$query = "INSERT INTO ".$dbN."`rp_users2` (`id`, `steamid`, `job_id`, `group_id`, `pseudo`, `steamid2`) VALUES ";
				$query .= "(NULL, '".$steamid."', '-1', '".$grade."', '".mysql_real_escape_string(utf8_decode($user->data['username']))."', '".$user->data['steamid']."');";
				mysql_query($query);
				mysql_query("UPDATE ".$dbN."`rp_users` SET `group_id`='".$grade."' WHERE `steamid`='".$steamid."' LIMIT 1"); 

				error_box("Fait", "Vous avez quitté votre groupe.", "/index.php?page=roleplay&game=".$_GET['game']."");
				exit;
			}
			else {

				$search = mysql_real_escape_string($_POST['search']);
				$search = substr($search, 0, 64);
				$search = preg_replace("/[^\w\x7F-\xFF\s]/", " ", $search);

				$good = trim(preg_replace("/\s(\S{1,2})\s/", " ", ereg_replace(" +", "  "," $search ")));
				$good = ereg_replace(" +", " ", $good);

				if( !$good ) {
					error_box("Erreur", "Cette recherche est invalide.", "/index.php?page=roleplay&game=".$_GET['game']."");
					exit;
				}

				$_PARSE['search'] = "";
				$found = array();
				$query = mysql_query("SELECT `steamid`,`name` FROM ".$dbN."`rp_users` WHERE `name` LIKE '%".$search."%' ORDER BY `last_connected` DESC LIMIT 10;");
				while($row = @mysql_fetch_array($query) ) {
					if( isset($found[$row['steamid']]) )
						continue;

					$found[$row['steamid']] = 1;
					$_PARSE['search'] .= "<li><input type='text' value='".$row['steamid']."' /> <div class='SteamProfiler right' title='".$row["steamid"]."' id='EvaluatedID'></div><br clear='all'/></li>\n";
				}

				$query = mysql_query("SELECT `steamid`,`uname` AS `name` FROM `srv_nicks` WHERE `uname` LIKE '%".$search."%' LIMIT 10;");
				while($row = @mysql_fetch_array($query) ) {
					if( isset($found[$row['steamid']]) )
						continue;

					$found[$row['steamid']] = 1;
					$_PARSE['search'] .= "<li><input type='text' value='".$row['steamid']."' /> <div class='SteamProfiler right' title='".$row["steamid"]."' id='EvaluatedID'></div><br clear='all'/></li>\n";
				}
				$query = mysql_query("SELECT `steamid`,`uname2` AS `name` FROM `srv_nicks` WHERE `uname2` LIKE '%".$search."%' LIMIT 10;");
				while($row = @mysql_fetch_array($query) ) {
					if( isset($found[$row['steamid']]) )
						continue;

					$found[$row['steamid']] = 1;
					$_PARSE['search'] .= "<li><input type='text' value='".$row['steamid']."' /> <div class='SteamProfiler right' title='".$row["steamid"]."' id='EvaluatedID'></div><br clear='all'/></li>\n";
				}

				$query = mysql_query("SELECT `steamid`,`username` AS `name` FROM `ts-x`.`phpbb3_users` WHERE `username` LIKE '%".$search."%' ORDER BY `user_lastvisit` DESC LIMIT 10;");
				while($row = @mysql_fetch_array($query) ) {
					if( isset($found[$row['steamid']]) )
						continue;

					$found[$row['steamid']] = 1;
					$_PARSE['search'] .= "<li><input type='text' value='".$row['steamid']."' /> <div class='SteamProfiler right' title='".$row["steamid"]."' id='EvaluatedID'></div><br clear='all'/></li>\n";
				}
				$query = mysql_query("SELECT `steamid`,`username_clean` AS `name` FROM `ts-x`.`phpbb3_users` WHERE `username_clean` LIKE '%".$search."%' ORDER BY `user_lastvisit` DESC LIMIT 10;");
				while($row = @mysql_fetch_array($query) ) {
					if( isset($found[$row['steamid']]) )
						continue;

					$found[$row['steamid']] = 1;
					$_PARSE['search'] .= "<li><input type='text' value='".$row['steamid']."' /> <div class='SteamProfiler right' title='".$row["steamid"]."' id='EvaluatedID'></div><br clear='all'/></li>\n";
				}

				display( parsetemplate( gettemplate('page_roleplay_info_search'), $_PARSE), 'RolePlay', 'RolePlay', 'location_roleplay');
				exit;
			}
		}
		
		
		$tpl = new raintpl();
		
		$req = mysql_query("SELECT * FROM ".$dbN."`rp_jobs` WHERE `is_boss`=1 AND `quota`>'0' ORDER BY `job_id` ASC;");
		$g_ActiveChef = array();
		$req2 = mysql_query("SELECT `rp_users`.`job_id`,UNIX_TIMESTAMP(`rp_users`.`last_connected`) AS `timestamp` FROM ".$dbN."`rp_users`,".$dbN."`rp_jobs` WHERE `rp_users`.`job_id`>'0' AND `rp_users`.`job_id`=`rp_jobs`.`job_id` AND `rp_jobs`.`is_boss`='1'");
		while( $row = mysql_fetch_array($req2) ) {
			if( ($row['timestamp']+7*24*60*60) > time() ) {
				$g_ActiveChef[$row['job_id']]++;
			}
		}

		$cap = mysql_fetch_array(mysql_query("SELECT `towerCap`, `nuclearCap`, `capItem` FROM ".$dbN."`rp_servers` WHERE `port`=27015;"));

		$array = array();
		$tpl->assign("game", "csgo");
		
		while( $row = mysql_fetch_array($req) ) {
			$warn_quota = $warn_chef = "";

			if( $row['quota']-2 > $row['current'] ) {
				$warn_quota = "color: red;";
			}
			if( $g_ActiveChef[$row['job_id']] <= 0 ) {
				$warn_chef = "color: red;";
			}
			
			$array[$row['job_id']] = $row;
			$array[$row['job_id']]["warn_quota"] = $warn_quota;
			$array[$row['job_id']]["warn_chef"] = $warn_chef;
			
		}
		$tpl->assign("job_list", $array);
		$tpl->assign("cap", $cap);

		unset($array);
		$req = mysql_query("SELECT * FROM ".$dbN."`rp_groups` WHERE `is_chef`=1 AND `stats`>=500 ORDER BY `stats` DESC;"); //ORDER BY `rang` ASC, `id` ASC;");
		while( $row = mysql_fetch_array($req) ) {
			$row['job_name'] = $row['name'];
			$buff = explode(" - ", $row['job_name']);
			$row['job_name'] = $buff[1];
			
			
			$array[$row['id']] = $row;
			$array[$row['id']]["stats2"] = pretty_number2($row['stats']);
		}
		$tpl->assign("group_list", $array);

		$myself = mysql_fetch_array( mysql_query("SELECT * FROM ".$dbN."`rp_users` WHERE `steamid`='".$user->data['steamid']."' LIMIT 1;"));
		$tpl->assign("myself", $myself);

		draw($tpl->draw("page_roleplay_info", $return_string=true), "roleplay");
		
		exit;
	}

	if( $_POST && isset($_POST['steamid']) ) {
		$url = $_SERVER['REQUEST_URI'];
		$steamid = mysql_real_escape_string($_POST['steamid']);
		
		$grade = intval($_POST['grade']);
		
		// On vérifie si on est bien le chef, du grade qu'on souhaite modifier.
		$myself = mysql_fetch_array( mysql_query("SELECT * FROM ".$dbN."`rp_users` WHERE `steamid`='".$user->data['steamid']."' LIMIT 1;"));
		$ok = false;

		if( $_GET['sub'] == 'job' ) {

			$req = mysql_fetch_array( mysql_query("SELECT * FROM ".$dbN."`rp_jobs` WHERE `job_id`='".$grade."' LIMIT 1") );
			$owngrade = mysql_fetch_array( mysql_query("SELECT * FROM ".$dbN."`rp_jobs` WHERE `job_id`='".$myself['job_id']."' LIMIT 1;"));

			if( ($myself['job_id'] == $grade && $req['is_boss'] == 1) || ($req['own_boss'] == $myself['job_id'] ) ) {
				$ok = true;
			}
			else if( $grade == 0 ) {
				$ok = true;
			}
			if( $myself['job_id'] == 2 ) {
				$ok = true;
			}
		}
		else if( $_GET['sub'] == 'group' ) {

			$req = mysql_fetch_array( mysql_query("SELECT * FROM ".$dbN."`rp_groups` WHERE `id`='".$grade."' LIMIT 1;") );
			$owngrade = mysql_fetch_array( mysql_query("SELECT * FROM ".$dbN."`rp_groups` WHERE `id`='".$myself['group_id']."' LIMIT 1;"));

			if( $owngrade['is_chef'] == 1 && $req['owner'] == $myself['group_id']  ) {
				$ok = true;
			}
			else if( $grade == 0 ) {
				$ok = true;
			}
			else if( ($myself['group_id']-1) == $req['owner'] ) {
				$ok = true;
			}
		}
		if( !$ok ) {
			error_box("Erreur", "Vous n'etes pas chef.", $url);
			exit;
		}
		// On vérifie maintenant le SteamID
		if( $_GET['game'] == "csgo" ) {
			$_POST['steamid'] = str_replace("STEAM_0", "STEAM_1", $_POST['steamid']);
			$steamid = $_POST['steamid'];
		}

		$target = mysql_fetch_array( mysql_query("SELECT * FROM ".$dbN."`rp_users` WHERE `steamid`='".mysql_real_escape_string($_POST['steamid'])."' LIMIT 1"));
		$ok = false;
		if( !$target ) {
			error_box("Erreur", "SteamID (".$steamid.") inconnu.");
			exit;
		}
		if( $_GET['sub'] == 'job' ) {
			if( $target['job_id'] == 0 || ceil($grade/10.0) == ceil($target['job_id']/10.0) ) {
				$ok = true;
			}
			if( $grade == 0 && ceil($target['job_id']/10.0) == ceil($myself['job_id']/10.0) ) {
				$ok = true;
			}
		}
		else if( $_GET['sub'] == 'group' ) {
			if( $target['group_id'] == 0 || ceil($grade/10.0) == ceil($target['group_id']/10.0) ) {
				$ok = true;
			}
			if( $grade == 0 && ceil($target['group_id']/10.0) == ceil($myself['group_id']/10.0) ) {
				$ok = true;
			}

			if( $myself['group_id'] == $target['group_id'] ) {
				$ok = false;
			}
			if( $myself['group_id'] == $grade ) {
				$ok = false;
			}
			
			if( $target['group_id'] == 0 ) {
				$wednesday = strtotime('wednesday this week +18 hours 30 minutes');
				$friday = strtotime('friday this week +21 hours 30 minutes');
				$time = time();
				$time2 = $time+(4*60*60);
				//$time2 = 0;
				
				if( $time < $wednesday && $time2 > $wednesday ) {
					die("hacking attempt.");
				}
				else if( $time < $friday && $time2 > $friday ) {
					die("hacking attempt.");
				}
			}
		}
		
		if( !$ok ) {
			error_box("Erreur", "Vous ne pouvez pas modifier le grade de cette personne..", $url);
			exit;
		}
		
		if( $_GET['sub'] == 'job' ) {
			$query = "INSERT INTO ".$dbN."`rp_users2` (`id`, `steamid`, `job_id`, `group_id`, `pseudo`, `steamid2`) VALUES ";
			$query .= "(NULL, '".$steamid."', '".$grade."', '-1', '".mysql_real_escape_string(utf8_decode($user->data['username']))."', '".$user->data['steamid']."');";
			mysql_query($query);
			mysql_query("UPDATE ".$dbN."`rp_users` SET `job_id`='".$grade."' WHERE `steamid`='".$steamid."' LIMIT 1"); 
			
			error_box("FAIT", "Le job de ".$target['name']." (".$steamid.") a &eacute;t&eacute; modifi&eacute;.", $url);
			exit;
		}
		else if( $_GET['sub'] == 'group' ) {
			$query = "INSERT INTO ".$dbN."`rp_users2` (`id`, `steamid`, `job_id`, `group_id`, `pseudo`, `steamid2`) VALUES ";
			$query .= "(NULL, '".$steamid."', '-1', '".$grade."', '".mysql_real_escape_string(utf8_decode($user->data['username']))."', '".$user->data['steamid']."');";
			mysql_query($query);
			mysql_query("UPDATE ".$dbN."`rp_users` SET `group_id`='".$grade."' WHERE `steamid`='".$steamid."' LIMIT 1"); 
			
			error_box("FAIT", "Le groupe de ".$target['name']." (".$steamid.") a &eacute;t&eacute; modifi&eacute;.", $url);
			exit;
		}
		
		
		exit;
	}
	
	$id = intval($_GET['id']);
	if( $_GET['ajax'] == 1 && isset($_GET['steamid']) ) {
		die(display_job_info($id, $_GET['steamid'], 0, $dbN));
	}

	$is_admin = false;
	if( $_GET['sub'] == 'job' ) {
		$row = @mysql_fetch_array( mysql_query("SELECT * FROM ".$dbN."`rp_jobs` WHERE `job_id`='".$id."' LIMIT 1"));
	}
	else if( $_GET['sub'] == 'group' ) {
		header("Location: index.php?page=roleplay2#/group/".$id."");
		exit;

		$row = @mysql_fetch_array( mysql_query("SELECT * FROM ".$dbN."`rp_groups` WHERE `id`='".$id."' LIMIT 1"));
		$row['job_name'] = $row['name'];
	}
	
	if( $row['is_boss'] != 1 && $row['is_chef'] != 1 ) {
		error_box("Erreur", "Cette page n'existe plus.", "index.php?page=roleplay&game=".$_GET['game']."");
		exit;
	}

	$tmp = $row['job_name'];
	$buff = explode(" - ", $row['job_name']);
        $row['job_name'] = $buff[1];
	if( strlen($row['job_name']) <= 1 ) {
		$row['job_name'] = $tmp;
	}

	
	$tpl = new raintpl();
	$tpl->assign("raw", $row);
	$tpl->assign("job_list", $job_list);
	

	if( $_GET['sub'] == 'job' ) {
		$query = mysql_query("SELECT * FROM ".$dbN."`rp_jobs` WHERE `job_id`='".$id."' OR `own_boss`='".$id."' LIMIT 20;");
	}
	else if( $_GET['sub'] == 'group' ) {
		$query = mysql_query("SELECT * FROM ".$dbN."`rp_groups` WHERE `id`='".$id."' OR `owner`='".$id."' LIMIT 20;");
	}

	while($row = mysql_fetch_array($query) ) {
		if( $_GET['sub'] == 'job' ) {
			$job_list[$row['job_id']] = $row;
		}
		else if( $_GET['sub'] == 'group' ) {
			$job_list[$row['id']] = $row;
		}
	}
	
	
	
	$g_USERS = array();
	$g_LOGS = array();
	
	if( $_GET['sub'] == 'job' ) {
		$query = mysql_query("SELECT * FROM ".$dbN."`rp_users` WHERE `job_id`>='".$id."' AND `job_id`<'".($id+10)."' AND `steamid`<>'STEAM_1:0:7490757' ORDER BY `job_id` ASC;");
	}
	else if( $_GET['sub'] == 'group' ) {
	
		$query = mysql_query( "SELECT * FROM ".$dbN."`rp_groups` WHERE `id`>0");
		while( $row = mysql_fetch_array($query) ) {
			$g_szGROUPS[$row['id']] = $row;
		}
		$query = mysql_query( "SELECT *,unix_timestamp(`last_connected`) as `timed` FROM ".$dbN."`rp_users` AND `steamid`<>'STEAM_1:0:7490757' WHERE `group_id`>'0'");
		while( $row = mysql_fetch_array($query) ) {
			$g_szUSERS[$row['steamid']] = $row;
		}

		$query = mysql_query("SELECT * FROM ".$dbN."`rp_users` WHERE `group_id`>='".$id."' AND `group_id`<'".($id+10)."' ORDER BY `group_id` ASC;");
	}

	$i=0; $array = array();
	while($row = mysql_fetch_array($query) ) {
		if( $_GET['sub'] == 'job' ) {
			$row['job_name'] = $job_list[$row['job_id']]['job_name'];
			$row['is_boss'] = $job_list[$row['job_id']]['is_boss'];
		}
		else if( $_GET['sub'] == 'group' ) {
			$row['job_name'] = $job_list[$row['group_id']]['name'];
			$row['is_chef'] = $job_list[$row['job_id']]['is_chef'];
		}

		if( $row['steamid'] == $user->data['steamid'] ) {

			if( $_GET['sub'] == 'job' && $job_list[$row['job_id']]['is_boss'] == 1 ) {
				$is_admin = true;
			}
			else if( $_GET['sub'] == 'group' && ($job_list[$row['group_id']]['is_chef'] == 1 || $job_list[$row['group_id']-1]['is_chef'] == 1)) {
				$is_admin = true;
			}
			if( $_GET['sub'] == 'job' && $job_list[$row['job_id']]['job_id'] == 2) {
                        $is_admin = true;
                  }
		}

		$row['name'] = utf8ToUnicodeEntities($row['name']);

		$g_USERS[$row['steamid']] = $row;
		if( (strtotime($row['last_connected'])+(7*24*60*60)) < time() ) {
			$row['name'] = '<s style="color:gray;">'.$row['name'].'</s>';
			$row['job_name'] = '<s style="color:gray;">'.$row['job_name'].'</s>';
		}

		if( group_memberships(19, $user->data['user_id'], true) ) {
			$row['admin'] = '<center><a href="/index.php?page=tribunal&action=case&steamid='.$row['steamid'].'"><img src="/images/icons/attack.png"/></a></center>';
		}
		$array[$i] = $row;
		$i++;
	}
	$tpl->assign("row_job", $array);
	$tpl->assign("admin", $is_admin);
	
	if( $_GET['sub'] == 'job' ) {
		if( $_POST && $_GET['action'] == 'editNote' && isset($_POST['txt']) ) {
			if( !$is_admin )
				error_box("Erreur", "Vous n'êtes pas responsable de ce job.", "/index.php?page=roleplay&game=".$_GET['game']."&sub=job&id=".$id."");

			$txt = mysql_real_escape_string($_POST['txt']);
			$val = intval($_POST['id']);
			$hidden = isset($_POST['hidden']);

			$sql = "UPDATE ".$dbN."`rp_notes` SET `txt`='".$txt."', `hidden`='".$hidden."' WHERE `id`=".$val.";";
			mysql_query($sql);

			error_box("Fait", "La note a &eacute;t&eacute; modifi&eacute;e.", "/index.php?page=roleplay&game=".$_GET['game']."&sub=job&id=".$id."");
			exit;
		}

		$i=0; $array = array();
		
		$req = mysql_query("SELECT * FROM ".$dbN."`rp_notes` WHERE `job_id`='".$id."' ORDER BY id ASC;");
		while($row = mysql_fetch_array($req) ) {
			$array[] = $row;
		}
		$tpl->assign("row_log", $array);

		
		$i=0; $array = array();
		
		$req = mysql_query("SELECT COUNT(`steamid`) as cnt, job_name, pay, rp_jobs.job_id FROM ".$dbN."`rp_jobs` LEFT JOIN ".$dbN."rp_users ON rp_users.job_id=rp_jobs.job_id WHERE rp_jobs.job_id=".$id." OR `own_boss`=".$id." GROUP BY rp_users.job_id ORDER BY rp_jobs.job_id");
		while($row = mysql_fetch_array($req) ) {
			$array[] = $row;
		}
		$tpl->assign("row_tree", $array);

		$i=0; $array = array();
		$query = mysql_query( "SELECT * FROM ".$dbN."`rp_users` U LEFT JOIN ".$dbN."`rp_rank` R ON U.steamid=R.steamid WHERE `type`='sell' ORDER BY `rank` ASC;");
		while( $row = mysql_fetch_array($query) ) {
			if( !isset($g_USERS[$row['steamid']]) )
				continue;

			$array[$i] = $g_USERS[$row["steamid"]];
			$array[$i]['point'] = $row['point'];

			$i++;
		}
		$tpl->assign("row_best", $array);

	}

	$tpl->assign("g_USERS", $g_USERS);
	$tpl->assign("job_list", $job_list);
	
	$wednesday = strtotime('wednesday this week +18 hours 30 minutes');
	$friday = strtotime('friday this week +21 hours 30 minutes');
	$time = time();
	$time2 = $time+(4*60*60);
//	$time2 = 0;

	if( count($g_USERS) >= 10 ) {
		$tpl->assign("count", 42);
		$tpl->assign("disableReason", "Vous êtes trop nombreux!");
	}
	else if( $time < $wednesday && $time2 > $wednesday ) {
		$tpl->assign("count", 42);
		$tpl->assign("disableReason", "Impossible de recruter un membre de mardi 18h30 à mercredi 16h30");
	}
	else if( $time < $friday && $time2 > $friday ) {
		$tpl->assign("count", 42);
		$tpl->assign("disableReason", "Impossible de recruter un membre de jeudi 21h30 à vendredi 21h30");
	}
	
	$tpl->assign("type", $_GET['sub']);
	$tpl->assign("id", $_GET['id']);
	
	

	if( $_GET['sub'] == 'job' ) {
		$tpl->assign("capital", display_job_info($id, 'CAPITAL', 0, $dbN));
	}
	if( $_GET['sub'] == 'group' ) {
		$cap = mysql_query("SELECT `towerCap`, `nuclearCap` FROM ".$dbN."`rp_servers` WHERE `port`=27015;");
		$cap = mysql_fetch_array($cap);
		$tpl->assign("cap", $cap);		
		$tpl->assign("capital", display_job_info($id, 'FORTUNE', 0, $dbN));
	}

	$_PARSE['game'] = $_GET['game'];
	if( $_GET['sub'] == 'job' ) {
		draw($tpl->draw("page_roleplay_info_job", $return_string=true), "roleplay", array("jquery.flot.min.js", "curvedLines.js"));
	}
	else if( $_GET['sub'] == 'group' ) {
		draw($tpl->draw("page_roleplay_info_group", $return_string=true), "roleplay",  array("jquery.flot.min.js", "curvedLines.js"));
	}
	
	

	exit;
?>
