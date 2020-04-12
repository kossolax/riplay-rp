<html>
<head>
<style>
* {
	background-color:black;
	color: white;
}
</style>
</head>
<body>
<?php
include_once('config.inc.php');


if( $_GET['edit'] ) {
	if( $_POST ) {
		$temp = explode(".", $_FILES["file"]["name"]);
		$extension = end($temp);

		$valid = false;
		if ($_FILES["file"]["error"] > 0) { die($_FILES["file"]["error"]);      }

		if( exif_imagetype($_FILES["file"]["tmp_name"]) == IMAGETYPE_PNG && $_FILES["file"]["type"] == "image/png" && $extension == "png" ) {
			$valid = true;
		}
		if( exif_imagetype($_FILES["file"]["tmp_name"]) == IMAGETYPE_JPEG && ($_FILES["file"]["type"] == "image/jpg" || $_FILES["file"]["type"] == "image/jpeg") && $extension == "jpg" ) {
                        $valid = true;
                }

		if( !$valid ) {
			die("hacking attempt.");
		}


		$dst = "/var/www/ts-x/images/roleplay/csgo/items/".$_GET['edit'].".png";

		$thumb = new Imagick($_FILES["file"]["tmp_name"]);
		$thumb->resizeImage(150,150,Imagick::FILTER_LANCZOS,1);
		$thumb->writeImage($dst);
		$thumb->destroy();

		header("Location: index.php");
		exit;
	}

	echo "J'accepte que des .png et .jpg";
	echo "<form action='index.php?edit=".$_GET['edit']."' method='post' enctype='multipart/form-data'>";
	echo "<input type='file' name='file'><input type='submit' name='submit' value='Envoyer'>";
	echo "</form>";
}
else {
	$req = mysql_query("SELECT * FROM rp_items") or die(mysql_error());
	echo "<table>";
	$i = -1;
	while( $row = mysql_fetch_array($req) ) {
		$i++;

		if( $i % 5 == 0 ) {
			echo "<tr>";
		}

		echo "<td>";
		echo "<a href='index.php?edit=".$row['id']."'>";
		echo "<img src='/images/roleplay/csgo/items/".$row['id'].".png' /><br />";
		echo "".$row['id'].". ".$row['nom']."</a>";
		echo "</td>";

		if( $i % 5 == 4 ) {
			echo "</tr>";
		}
	}

	echo "</table>";
}
?>
</body>
</html>
