<?php

if( $_GET['type'] == 'config' && isset($_GET['id']) ) {

	$prive = 0;
	$passe = '';
	$video = 0;
	$id = mysql_real_escape_string($_GET['id']);

	if( $_GET['config'] == 'private' && isset($_GET['pass']) ) {
		$prive = 1;
		$passe = mysql_real_escape_string($_GET['pass']);
	}
	if( $_GET['config'] == 'video' ) {
		$video = 1;
	}

	$row = mysql_fetch_array(mysql_query("SELECT * FROM `site_upload` WHERE `id`='".$id."' LIMIT 1;", $g_hBDD));
	if( $row['is_config'] == 1 ) {
		header('Location: index.php?page=download');
		exit;
	}
	
	mysql_query("UPDATE `site_upload` SET `is_config`='1', `is_prive`='".$prive."', `password`='".$passe."', `is_video`='".$video."' WHERE `id`='".$id."' LIMIT 1;", $g_hBDD);
	
	$msg = "<span style='font-size:12px'>Votre fichier a été envoyé avec succès.";
	if( $video ) {
		$msg .= "<br />L'encodage de la vidéo prend du temps, un icone sera disponible devant son lien dès qu'elle sera lisible depuis un lecteur.";
	}
	$msg .= "<br /><br />&bull; Votre fichier: ".$row['nom_fichier']."</span>";

	error_box("Envois terminé", $msg, "index.php?page=download");
	exit;
}
if( isset($_GET['uid']) ){
	header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
	header('Last-Modified: '.gmdate('D, d M Y H:i:s').' GMT');
	header('Cache-Control: no-store, no-cache, must-revalidate');
	header('Cache-Control: post-check=0, pre-check=0', FALSE);
	header('Pragma: no-cache');

	$progress = apc_fetch('upload_'. $_GET['uid']);
	echo ''.$progress['current'].':'.$progress['total'].':'.$progress['done'].'';
	exit;
}
if( $_GET['type'] == 'sent' ){
	if($_FILES['file']['error'] == UPLOAD_ERR_OK ){

		$uid = uniqid(true);

		$req = "INSERT INTO `site_upload` (`id`, `user_id`, `uniq_id`, `nom_fichier`, `is_prive`, `password`, `is_video`, `timestamp_ld`, `timestamp_hd`, `timestamp`)";
		$req .= " VALUES ( NULL, '".$user->data['user_id']."', '".$uid."', '".mysql_real_escape_string(basename($_FILES['file']['name']))."',";
		$req .= " '0', '', '0', '-1', '-1', '".time()."');";

		mysql_query($req, $g_hBDD);
		$id = mysql_insert_id($g_hBDD);

		$filepath = 'files/';
		$filepath .= ''.$uid.'.'.GetFileExtension( basename($_FILES['file']['name']) ); 

		if( @move_uploaded_file($_FILES['file']['tmp_name'], $filepath) ) {
			echo $id;
		}
		else {
			echo "-2";
		}
	}
	else {
		echo "-1";
	}
	exit;
}

if( $user->data['user_id'] == ANONYMOUS ) {
	error_box("Erreur", "Vous devez être connecté afin d'envoyer un fichier.", "index.php");
	exit;
}
	
	$tpl = new raintpl();
	$tpl->assign('uid', uniqid());
	draw($tpl->draw("page_upload", $return_string=true), "Envois de fichier", array("upload.js?v=2") );

?>
