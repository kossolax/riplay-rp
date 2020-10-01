<?php
function hsl_to_rgb($h, $s, $l){

        $r = $l;
        $g = $l;
        $b = $l;
        $v = ($l <= 0.5) ? ($l * (1.0 + $s)) : ($l + $s - $l * $s);
        if ($v > 0){
              $m;
              $sv;
              $sextant;
              $fract;
              $vsf;
              $mid1;
              $mid2;

              $m = $l + $l - $v;
              $sv = ($v - $m ) / $v;
              $h *= 6.0;
              $sextant = floor($h);
              $fract = $h - $sextant;
              $vsf = $v * $sv * $fract;
              $mid1 = $m + $vsf;
              $mid2 = $v - $vsf;

              switch ($sextant)
              {
                    case 0:
                          $r = $v;
                          $g = $mid1;
                          $b = $m;
                          break;
                    case 1:
                          $r = $mid2;
                          $g = $v;
                          $b = $m;
                          break;
                    case 2:
                          $r = $m;
                          $g = $v;
                          $b = $mid1;
                          break;
                    case 3:
                          $r = $m;
                          $g = $mid2;
                          $b = $v;
                          break;
                    case 4:
                          $r = $mid1;
                          $g = $m;
                          $b = $v;
                          break;
                    case 5:
                          $r = $v;
                          $g = $m;
                          $b = $mid2;
                          break;
              }
        }
        return array('r' => $r * 255.0, 'g' => $g * 255.0, 'b' => $b * 255.0);
}
function make_color($value, $min = 0, $max = .5)
{
    $ratio = $value;
    if ($min > 0 || $max < 1) {
        if ($value < $min) {
            $ratio = 1;
        } else if ($value > $max) {
            $ratio = 0;
        } else {
            $range = $min - $max;
            $ratio = ($value - $max) / $range;
        }
    }

    $rgb = hsl_to_rgb( $ratio, 1, .5);

    $r = round($rgb['r'], 0);
    $g = round($rgb['g'], 0);
    $b = round($rgb['b'], 0);

    return "rgb($r,$g,$b)";
}

	if( $_GET['action'] == "ind" ) {
		$q = mysql_real_escape_string($_GET['q']);
		$v = intval($_GET['v']);
		$steamid = str_replace("STEAM_1", "STEAM_0", mysql_real_escape_string($_GET['target']));
		$req = mysql_query("SELECT `".$q."` FROM `ts-x`.`site_sondage` WHERE `target`='".$steamid."' AND TRIM(`".$q."`)!='';") or die(mysql_error());

		$i = 0;
		while($row = mysql_fetch_array($req) ) {
			if( $i == $v ) {
				echo $row[0];
				exit;
			}
			$i++;
		}
		exit;
	}
	if( $_GET['action'] == 'result' ) {
		$steamid = mysql_real_escape_string($_GET['target']);
		$tpl = new raintpl();
		$data = array();
		$data2 = array();
		$admin = array();
		
		$sql = "SELECT U.`name`, REPLACE(steamid, 'STEAM_1', 'STEAM_0') as `steamid` FROM `rp_csgo`.`rp_users` U WHERE U.`steamid`='".str_replace("STEAM_0", "STEAM_1", $steamid)."' LIMIT 1;";
		$admin = @mysql_fetch_array(mysql_query($sql));
		
		$sql = "SELECT S.`target` as `target`, U.`name` as `name` FROM `ts-x`.`site_sondage` S INNER JOIN `rp_csgo`.`rp_users` U ON U.`steamid`=REPLACE(S.`target`, 'STEAM_0', 'STEAM_1') GROUP BY S.`target`";
		$query = mysql_query($sql);
		while( $row = mysql_fetch_array( $query ) ) {
			$admins[ $row['target'] ] = $row['name'];
		}
		
		$query = mysql_query("SELECT * FROM `site_sondage` WHERE `target`='".$steamid."';");
		
		while( $row = mysql_fetch_array( $query ) ) {
			$total++;

			foreach($row as $key => $value) {
				if( $key == "steamid" )
					continue;
				if( !is_numeric($value) ) {
					if( strlen($value)>=1 ) {
						$arr = explode(",", $value);
						$skip = false;
						foreach( $arr as $k ) {
							if( !is_numeric($k) )
								$skip = true;
						}
						if( !$skip ) {
							foreach( $arr as $k ) {
								$data["".$key."at".$k.""]++;
								$data2["$key"]++;
							}
						}
					}

					continue;
				}

				$data["".$key."at".$value.""]++;
				$data2[$key]++;
			}
		}

		foreach( $data as $key => $value ) {
			$tpl->assign($key, "<span class='sres' style='color: ".make_color(1 - $value/$data2[substr($key, 0, strpos($key, "at"))])."'><br />".round($value/$data2[substr($key, 0, strpos($key, "at"))] * 100, 1)."% (".$value.")</span>");
		}
		
		$tpl->assign("total", $total);
		$tpl->assign("admin", $admin);
		$tpl->assign("admins", $admins);
		draw($tpl->draw("page_sondage_result", $return_string=true), "Sondage");
		exit;
	}


	if( $user->data['user_id'] == ANONYMOUS ) {
		error_box("Erreur", "Vous devez être connecté pour accèder à cette page.", "/index.php");
	}
	mysql_select_db("ts-x");
	$steamid = mysql_real_escape_string($user->data['steamid']);

	if( $_GET['action'] == 'post' ) {
		$db = array();
		$query = "INSERT INTO `site_sondage` (`steamid`, ";
		foreach($_POST as $key => $value) {
			if( !preg_match("/q[0-9]{1,2}/", $key) && $key != "target" )
				die("Hacking attempt");

			if( is_array($value) ) {
				$value = implode(",", $value);
			}

			if( strlen(trim($value)) == 0 )
				continue;

			$db[mysql_real_escape_string($key)] = mysql_real_escape_string($value);
			$query .= "`".mysql_real_escape_string($key)."`, ";
		}
		$query = substr($query, 0, -2)." ) VALUES ( '".$steamid."', ";
		foreach($db as $key => $value) {
			$query .= "'".$value."', ";
		}
		$query = substr($query, 0, -2)." );";
		mysql_query($query) or die("Il y a eut une erreur lors de l'envois de vos réponses. Contactez un administrateur s'il vous plait !\n\n\n\n\nErreur: ". mysql_error() );
		mysql_query("INSERT INTO `rp_csgo`.`rp_users2` (`id`, `steamid`, `xp`, `pseudo`) VALUES (NULL, '".$steamid."', '5000', 'Sondage');");
		error_box("Envoyé", "Vos réponses ont bien été envoyées, et nous vous en remercions.", "/index.php");
		exit;
	}
	if( @mysql_fetch_array(mysql_query("SELECT * FROM `site_sondage` WHERE `steamid`='".$steamid."' AND `time`+24*10*60*60 > UNIX_TIMESTAMP()")) ) {
		error_box("Erreur", "Vous avez déjà répondu au sondage.", "/index.php");
		exit;
	}

	$isNew = @mysql_fetch_array(mysql_query("SELECT * FROM `rp_csgo`.`rp_idcard` WHERE `steamid`='".str_replace("STEAM_0", "STEAM_1", $steamid)."' AND `played` < 72000"));

	$sql = "SELECT G.`name` as `rank`, SUBSTRING(A.`name`, (CASE LOCATE(' - ', A.`name`) WHEN 0 THEN 1 ELSE LOCATE(' - ', A.`name`)+3 END)) as `name`, `identity` as `steamid` FROM `ts-x`.`sm_admins` A";
	$sql .= "	INNER JOIN `rp_csgo`.`rp_users` U ON U.`steamid`=REPLACE(A.`identity`, 'STEAM_0', 'STEAM_1')";
	$sql .= "	INNER JOIN `ts-x`.`sm_admins_groups` AG ON AG.`admin_id`=A.`id`";
	$sql .= "	INNER JOIN `ts-x`.`sm_groups` G ON AG.`group_id`=G.`id`";
	$sql .= "	INNER JOIN `ts-x`.`phpbb3_users` F ON REPLACE(F.`steamid`, 'STEAM_0', 'STEAM_1')=U.`steamid`";
	$sql .= "	WHERE U.`time_played` >= 1 AND F.`group_id` IN (18, 19, 67, 68)";
	$sql .= "	GROUP BY `steamid` ORDER BY rand() LIMIT 1";

	$admin = @mysql_fetch_array(mysql_query($sql));

	$tpl = new raintpl();
	$tpl->assign("isNew", $isNew);
	$tpl->assign("admin", $admin);

	draw($tpl->draw("page_sondage", $return_string=true), "Sondage");
?>
