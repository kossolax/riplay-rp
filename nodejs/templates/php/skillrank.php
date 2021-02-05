<?php

	if( $_GET['action'] == 'playerinfo' ) {
		$steamid = mysql_real_escape_string($_GET['steamid']);
		
		$sql  = "SELECT * FROM `sr_maps_record`, `sr_maps_config`, `srv_nicks` WHERE ";
		$sql .= " `sr_maps_record`.`map`=`sr_maps_config`.`map` AND `sr_maps_record`.`steamid`=`srv_nicks`.`steamid` AND `sr_maps_record`.`steamid`='".$steamid."'";
		$sql .= " ORDER BY `sr_maps_config`.`point` DESC;";
		
		$sql = mysql_query($sql);
		
		
		while( $row = mysql_fetch_array($sql) ) {
			if( $row['point'] <= 0 )
				$row['point'] = 0;
			
			$data[$row['map']] = $row;
			
			$nick = $row['uname2'];
		}
		
		$_PARSE['joueur_info'] = $nick;
		
		foreach( $data as $key => $value ) {
			$_PARSE['joueur_list'] .= "<li><a href='/index.php?page=skillrank&action=mapinfo&mapname=".$key."' >".$key." - ".$value['time']."</a></li>";
		}
	}
	else if( $_GET['action'] == 'mapinfo' ) {
		$map = mysql_real_escape_string($_GET['mapname']);
		
		$sql  = "SELECT * FROM `sr_maps_record`, `sr_maps_config`, `srv_nicks` WHERE ";
		$sql .= " `sr_maps_record`.`map`=`sr_maps_config`.`map` AND `sr_maps_record`.`steamid`=`srv_nicks`.`steamid` AND `sr_maps_record`.`map`='".$map."'";
		$sql .= " ORDER BY `sr_maps_record`.`time` ASC;";
		
		$sql = mysql_query($sql);
		
		while( $row = mysql_fetch_array($sql) ) {
			if( $row['point'] <= 0 )
				$row['point'] = 0;
			
			$data[$row['steamid']] = $row;
			
			$nick = $row['uname2'];
		}
		
		$_PARSE['joueur_info'] = $map;
		
		foreach( $data as $key => $value ) {
			$_PARSE['joueur_list'] .= "<li><a href='/index.php?page=skillrank&action=playerinfo&steamid=".$key."' >".$value['uname2']." - ".$value['time']."</a></li>";
		}
	}
	else {
		
		
		$sql = mysql_query("SELECT * FROM `sr_maps_record`, `sr_maps_config`, `srv_nicks` WHERE `sr_maps_record`.`map`=`sr_maps_config`.`map` AND `sr_maps_record`.`steamid`=`srv_nicks`.`steamid`");
		while( $row = mysql_fetch_array($sql) ) {
			if( $row['point'] <= 0 )
				continue;
			
			$data[$row['steamid']] += $row['point'];
			$data_nick[$row['steamid']] = $row['uname2'];
		}
		arsort($data);
	
		$_PARSE['joueur_info'] = "général";
		foreach( $data as $key => $value ) {
			$_PARSE['joueur_list'] .= "<li><a href='/index.php?page=skillrank&action=playerinfo&steamid=".$key."' >".$data_nick[$key]."</a></li>";
		}
	}
	
	display( parsetemplate( gettemplate('page_skillrank'), $_PARSE), 'Skill-Rank', 'Skill-Rank', 'location_serveur');

	exit;
?>
