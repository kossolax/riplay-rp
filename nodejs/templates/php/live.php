<?php
//	error_box("SOON", "KOM BACK SOON", "index.php");
/*if ( $_SERVER['HTTPS'] === 'on' ) {
    $url = "http://". $_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI'];
    header("Location: $url");
    exit;
} */


$tpl = new raintpl();
draw($tpl->draw("live", $return_string=true), "IRC" );

?>
