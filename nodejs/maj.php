<?php

function write($img, $txt, $x, $y, $size) {
	$black = imagecolorallocatealpha($img,   0,   0,   0, 64);
	$white = imagecolorallocatealpha($img, 255, 255, 255, 16);
	$fontfile = "/home/www/rp/fonts/calibri.ttf";

	for($i=-1; $i<=1; $i++) {
		for($j=-1; $j<=1; $j++) {
			imagettftext($img, $size, 0, $x+$i, $y+$j, $black, $fontfile, $txt);
		}
	}

	imagettftext($img, $size, 0, $x+2, $y+2, $black, $fontfile, $txt);
	return imagettftext($img, $size, 0, $x, $y, $white, $fontfile, $txt);
}

$img = imagecreatetruecolor(512, 256);
$bg = imagecreatefrompng('/home/autorun/bg.png');

imagecopyresampled($img, $bg, 0, 0, 0, 0, 512, 256, 512, 256);

$json = json_decode(file_get_contents("http://5.196.39.48:8080/live/update?cache=no"));
$i = 0;
foreach($json as $data) {
	if( strlen($data->message) <= 10 )
		continue;
	if( strpos($data->message, "Update ") === 0 )
		continue;
        if( strpos($data->message, "Merge ") === 0 )
                continue;

        $msg = trim(explode("Co-authored-by:", $data->message, 2)[0]);
	$tab = explode(":", $msg, 2);
	$title = trim($tab[0]);
	@$subtitle = trim($tab[1]);

	$pos = write($img, "- " .$title, 10, 55+$i*26, 18);
	if( strlen($subtitle) >= 1 ) {
		write($img, $subtitle, 4+$pos[4], 55+$i*26, 10);
	}

	if( $i >= 6 )
		break;

	$i++;
}
write($img, "riplay.fr", 6, 252, 12);
write($img, date("d-m-y à H\hi", strtotime($json[0]->date)), 396, 252, 12);

header('Content-Type: image/png');
if( php_sapi_name() != 'cli' ) {
	imagepng($img);
}
imagepng($img, "/home/autorun/fg.png");
imagedestroy($img);

if( $_POST || php_sapi_name() == 'cli' ) {
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_POST, true);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
	curl_setopt($ch, CURLOPT_URL, "https://rpweb.riplay.fr/images/roleplay/group/toto.php");

	$args = array();
	$args["image"] = new \CurlFile("/home/autorun/fg.png", "image/png", "fg.png");
	$args["envoyer"] = "oui";

	curl_setopt($ch, CURLOPT_POSTFIELDS, $args);

	$res = curl_exec($ch);

	if( php_sapi_name() == 'cli' ) {
		var_dump($res);
	}
}

?>
