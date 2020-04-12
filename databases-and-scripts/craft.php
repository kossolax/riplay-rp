<!DOCTYPE html>
<html lang="fr">
<head>
	<meta charset="utf-8">
	<style>
	* {
		padding: 0;
		margin: 0;
	}
	ul {
		list-style-type: none;
		padding: 5px;
		margin: auto;
	}
	body > ul > li {
		padding: 1px;
		float: left;
		width: 19%;
		min-height: 200px;
		background-color: #aaa;
		border: 1px solid black;
		text-align: center;
	}
	body > ul > li > ul {
		text-align: left;
	}
	.success {
		background-color: #afa;
	}
	.half {
		background-color: #ffa;
	}
	.danger {
		background-color: #faa;
	}
	</style>
</head>
<body>
	&bull; <span class="success">VERT</span> = Le prix correspond au craft. &bull; <span class="half">JAUNE</span> = Le prix est un peu trop cher.
	&bull; <span class="danger">ROUGE</span> = Le prix ne correspond pas au craft. &bull; <span style="background-color: #aaa;">GRIS</span> = Pas de craft.
<?php
include_once('config.inc.php');

if( !$_GET['action'] ) {
	echo "&bull; <a href='craft.php?action=edit'>Mode édition</a>&nbsp;&nbsp;&nbsp;";
}

$itemList = $craftList = $rawList = array();

$q = mysql_query("SELECT * FROM `rp_items` WHERE `auto_use`=0 AND `extra_cmd`<>'UNKNOWN';");
while($row = mysql_fetch_array($q) ) {
	$itemList[$row['id']] = $row;
}
$q = mysql_query("SELECT * FROM `rp_items` I INNER JOIN `rp_craft` C ON C.`itemid`=I.`id` ORDER BY `raw`");
while($row = mysql_fetch_array($q) ) {
        $craftList[$row['itemid']][] = $row;
}
$q = mysql_query("SELECT * FROM `rp_items` WHERE `extra_cmd` LIKE 'rp_item_primal%'");
while($row = mysql_fetch_array($q) ) {
        $rawList[] = $row;
}

if( $_POST ) {
	$fh = fopen("craft.txt", 'a');
	fwrite($fh, strftime("[%d-%b-%Y|%H:%M:%S] ", time()) ." ".$user->data['username']."(".$user->data['steamid'].") a modifier la recette de ".$itemList[intval($_POST['itemid'])]['nom'].", il a ajoute ".intval($_POST['amount'])." ".$itemList[intval($_POST['raw'])]['nom']."\n");
	fclose($fh);
	mysql_query("DELETE FROM `rp_craft` WHERE `itemid`='".intval($_POST['itemid'])."' AND `raw`='".intval($_POST['raw'])."';");
	if( intval($_POST['amount']) > 0 ) {
		mysql_query("INSERT INTO `rp_craft` (`id`, `itemid`, `raw`, `amount`) VALUES (NULL, '".intval($_POST['itemid'])."', '".intval($_POST['raw'])."', '".intval($_POST['amount'])."');");
	}
	header("Location: craft.php?action=edit#".intval($_POST['itemid'])."");
	exit;
}



function addRaw($id) {
	global $rawList, $_GET;
	if( $_GET['action'] != "edit" )
		return;
	echo "<form method='POST'>";
	echo "<input type='text' name='amount' value='1' size='3'/><select name='raw'>";
	foreach( $rawList as $k ) {
		echo "<option value='".$k['id']."'>".$k['nom']." (".$k['prix']."$, ".getRate($k['id'])."%)</option>";
	}
	echo "</select><input type='hidden' name='itemid' value='".$id."' />";
	echo "<input type='submit' value='Ajouter'>";
	echo "</form>";
}
function getRate($id) {
	global $itemList;
	return intval(str_replace("rp_item_primal ", "", $itemList[$id]['extra_cmd']));
}
function sumRaw($id) {
	global $itemList, $craftList;
	$sum = 0.0;
	if( $craftList[$id] ) {
		foreach( $craftList[$id] as $w ) {
			$sum += $w['amount'] * $itemList[$w['raw']]['prix'];/* * (getRate($w['raw'])/100.0);*/
		}
	}
	return $sum;
}
function getClass($k) {
	global $itemList;

	if( sumRaw($k) >= $itemList[$k]['prix']*1.2 )
                return 'danger';
	if( sumRaw($k) >= $itemList[$k]['prix']*0.85 )
		return 'half';
	if( sumRaw($k) >= $itemList[$k]['prix']*0.8 )
		return 'success';
	if( sumRaw($k) == 0 )
		return '';
	return 'danger';
}
function aasort (&$array, $key) {
    $sorter=array();
    $ret=array();
    reset($array);
    foreach ($array as $ii => $va) {
        $sorter[$ii]=$va[$key];
    }
    asort($sorter);
    foreach ($sorter as $ii => $va) {
        $ret[$ii]=$array[$ii];
    }
    $array=$ret;
}
aasort( $itemList, "extra_cmd");


echo "<ul>";
foreach( $itemList as $k => $v ) {
	$skip = false;
	foreach( $rawList as $w ) {
		if( $k == $w['id'] )
			$skip = true;
	}
	if( $skip )
		continue;
	echo "<li id='".$k."' class='".getClass($k)."'><b>".$v['nom']."</b>: <br />".sumRaw($k)." / ".$v['prix']." $";

	if( isset($craftList[$k]) ) {
		echo "<ul>";
		foreach( $craftList[$k] as $w ) {
			echo "<li>".$w['amount']."x <b>".$itemList[$w['raw']]['nom']."</b> (".$itemList[$w['raw']]['prix']."$, ".getRate($w['raw'])."%)</li>";
		}
		echo "</ul>";
	}
	addRaw($k);

	echo "</li>";
}
echo "</ul>";
?>
</body>
</html>
