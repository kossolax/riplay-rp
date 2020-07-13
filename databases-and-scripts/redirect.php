<?php
require_once '/home/www/forum/init.php';
require '/home/www/rp/include/steamauth/openid.php';

session_start();
header('Cache-Control: no-cache');
header('Pragma: no-cache');

if( !isset($_SESSION['steamid']) ) {

	\IPS\Session\Front::i();
	$member = \IPS\Member::loggedIn();
	if( !empty($member->steamid) )
		$_SESSION['steamid'] = $member->steamid;
}

if( !isset($_SESSION['steamid']) ) {
	try {
		$openid = new LightOpenID("https://rpweb.riplay.fr");

		if(!$openid->mode) {
			$openid->identity = 'https://steamcommunity.com/openid';
			header('Location: ' . $openid->authUrl());
			exit;
		} else {
			if($openid->validate()) {
				$id = $openid->identity;
				$ptn = "/^https?:\/\/steamcommunity\.com\/openid\/id\/(7[0-9]{15,25}+)$/";
				preg_match($ptn, $id, $matches);

				$_SESSION['steamid'] = $matches[1];
			}
		}
	} catch(ErrorException $e) {

	}
}

if( isset($_SESSION['steamid']) ) {
	$database = new PDO('mysql:host=localhost;dbname=rp_shared', 'rp_csgo', 'DYhpWeEaWvDsMDc9');

	$sql = $database->prepare("SELECT `url` FROM `rp_shared`.`urls` WHERE `steamid` = :steamid");
	$sql->execute(['steamid' => $_SESSION['steamid']]);
	$result = $sql->fetch(PDO::FETCH_ASSOC);

	if($result == null) {
		header("Location: index.php");
		exit;
	}
	header("Location: ".$result['url']." ");
	exit;
}
header("Location: redirect.php");
exit;
