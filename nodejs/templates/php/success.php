<?php
mysql_select_db("rp_csgo");

if( isset($_GET['img']) ) {
	$image = imagecreatefromjpeg("/var/www/ts-x/images/success_v2/".$_GET['img'].".jpg");
	$watermark = imagecreatefrompng("/var/www/ts-x/images/achievementWatermark.png");
	$lock = imagecreatefrompng("/var/www/ts-x/images/achievementLock.png");

	imagecopyresampled($image, $watermark, 0, 0, 0, 0, 200, 200, 200, 200);
	imagecopyresampled($image, $watermark, 0, 0, 0, 0, 200, 200, 200, 200);

        if( $_GET['type'] == 'disabled' ) {
		imagefilter($image, IMG_FILTER_GRAYSCALE);
		imagecopyresampled($image, $lock, 0, 0, 0, 0, 200, 200, 200, 200);
        }

        header("Content-type: image/jpeg");
	header('Cache-Control: public');
        header('Expires: '.gmdate('D, d M Y H:i:s \G\M\T', time() + (7 * 24 * 60 * 60)));
        header('Last-Modified: '.gmdate('D, d M Y H:i:s \G\M\T', time() + (7 * 24 * 60 * 60)));
        imagejpeg($image, NULL, 100);
        imagedestroy($image);

	exit;
}
if( !isset($_GET['steamid']) ) {
	if( isset( $user->data['steamid'] ) && $user->data['steamid'] != 'notset' ) {
		header("Location: http://www.ts-x.eu/index.php?page=success&steamid=".$user->data['steamid']."");
		exit;
	}
	else {
		error_box("Erreur", "SteamID non définit", "index.php");
		exit;
	}
}



$_GET['steamid'] = str_replace("STEAM_0", "STEAM_1", $_GET['steamid']);
$query = "SELECT `rp_success`.*,`rp_users`.`name` FROM `rp_success`, `rp_users` WHERE `rp_success`.`SteamID`='".mysql_real_escape_string($_GET['steamid'])."'";
$query .=" AND `rp_success`.`SteamID`=`rp_users`.`SteamID` LIMIT 1;";


$query = mysql_query($query, $g_hBDD) or die(mysql_error());
$row = mysql_fetch_array($query);

$cpt = 0;
$tpl = new raintpl();
$tpl->assign("name", utf8ToUnicodeEntities($row['name']));
foreach($SuccessData as $val => $value ) {

	$data = explode(" ", $row[ $SuccessData[$val][0] ]);
	$SuccessData[$val][4] = intval( $data[0] );
	$SuccessData[$val][5] = intval( $data[1] );
	$SuccessData[$val][6] = intval( $data[2] );

	if( intval( $data[0] ) >= 1 )
		$cpt++;

}
$tpl->assign("SuccessData", $SuccessData);
$tpl->assign("cpt", $cpt);

draw($tpl->draw("page_success", $return_string=true), "Succès de ".utf8ToUnicodeEntities($row['name']) );

?>
