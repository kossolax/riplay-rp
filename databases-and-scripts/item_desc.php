<html>
<head>
<meta charset="utf-8">
<style>
* {
	background-color:black;
	color: white;
}
input, textarea {
	display:block;
	width: 100%;
	heiht: 100px;
}
.red {
	background-color:red;
}
.green {
        background-color:green;
}
</style>
</head>
<body>
<?php

include_once('config.inc.php');

if( $_POST ) {
	$id = intval($_POST['id']);
	$desc = mysql_real_escape_string($_POST['desc']);
	mysql_query("UPDATE `rp_items` SET `description`='".$desc."' WHERE `id`='".$id."' LIMIT 1") or die(mysql_error());
}

$req = mysql_query("SELECT * FROM rp_items WHERE `extra_cmd`<>'UNKNOWN';") or die(mysql_error());
echo "<table>";
$i = -1;
while( $row = mysql_fetch_array($req) ) {
	$i++;
	if( $i % 5 == 0 ) {
		echo "<tr>";
	}

	echo "<td>";
	echo "<b>".$row['id'].". ".utf8_encode($row['nom'])."</b>";
	echo "<form method='POST'>";
	echo "<textarea name='desc'>".$row['description']."</textarea>";
	echo "<input type='hidden' name='id' value='".$row['id']."' />";
	echo "<input type='submit' value='Envoyer' class='". (empty($row['description']) ? 'red' : 'green') ."' />";
	echo "</form>";
	echo "</td>";

	if( $i % 5 == 4 ) {
		echo "</tr>";
	}
}
echo "</table>";
?>
</body>
</html>
