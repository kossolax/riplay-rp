<?php

if( $_GET['action'] == 'remove' ) {
	
	$id = mysql_real_escape_string($_GET['id']);
	$row = mysql_fetch_array(mysql_query("SELECT * FROM `site_upload` WHERE `id`='".$id."' LIMIT 1;"));
	
	if( !isset( $row['id'] ) ) {
		error_box('Erreur', "Ce fichier n'existe pas, ou plus.", "/index.php?page=download");
		exit;
	}
	
	if( $user->data['user_id'] != $row['user_id'] && $user->data['user_id'] != 2 ) {
		error_box('Erreur', "Ce fichier n'existe pas, ou plus.", "/index.php?page=download");
		exit;
	}
	

	$real = $row['nom_fichier'];
	$file = $row['uniq_id'].'.'.GetFileExtension($real);
	@unlink("files/".$file."");
	@unlink("files/video/".$file."_hd.flv");
	@unlink("files/video/".$file."_ld.flv");
	@unlink("files/video/".$file."_pic.jpg");

	mysql_query("DELETE FROM `site_upload` WHERE `site_upload`.`id`='".$id."' LIMIT 1;");
	error_box('Erreur', "Le fichier a &eacute;t&eacute; supprim&eacute; avec succ&egrave;s.", "/index.php?page=download");
	exit;
}

if( isset($_GET['file']) ) {
	$id = mysql_real_escape_string($_GET['file']);

	$row = mysql_fetch_array(mysql_query("SELECT * FROM `site_upload` WHERE `id`='".$id."' LIMIT 1;"));

	if( $row['is_prive'] ) {
		if( $row['password'] != $_GET['pass'] ) {
			error_box('Erreur', "Le mot de passe entré est invalide.", "/index.php?page=download");

			exit;
		}
	}
	if( !isset( $row['id'] ) ) {
		error_box('Erreur', "Ce fichier n'existe pas, ou plus.", "/index.php?page=download");
		exit;
	}

	mysql_query("UPDATE `site_upload` SET `downloaded`=`downloaded`+1 WHERE `id`='".$id."' LIMIT 1;");

	$real = $row['nom_fichier'];
	$file = $row['uniq_id'].'.'.GetFileExtension($real);

	$taille = filesize("files/".$file."");

	header("Content-Type: application/force-download; name=\"$file\"");
	header("Content-Transfer-Encoding: binary");
	header("Content-Length: $taille");
	header("Content-Disposition: attachment; filename=\"$real\"");
	header("Expires: 0");
	header("Cache-Control: no-cache, must-revalidate");
	header("Pragma: no-cache");
	readfile("files/$file");
	exit;
}

	$query = mysql_query("SELECT * FROM `site_upload` S INNER JOIN `phpbb3_users` U ON S.`user_id`=U.`user_id` WHERE `is_config`='1' ORDER BY `is_prive` ASC, `timestamp` DESC");

	$array = array(); $i=0;
	while( $row = mysql_fetch_array($query) ) {
		$i++;
		$array[$i] = $row;
		$array[$i]['ext'] = GetFileExtension($row['nom_fichier']);
		$array[$i]['pic'] = IsFilePic($row['nom_fichier']);
	}

	$tpl = new raintpl();
	$tpl->assign('row', $array);
	$tpl->assign('userID', $user->data['user_id']);
	
	draw($tpl->draw("page_download", $return_string=true), "Téléchargement de fichier", array("upload.js"));
	
?>
