<?php

$tpl = new raintpl();

if( $_GET['alt'] ) {
	$_GLOBAL['alternative'] = $_GET['alt'];
	$tpl->assign("alt", $_GET['alt']);
}


draw($tpl->draw("page_alternative", $return_string=true), "test" );

?>
