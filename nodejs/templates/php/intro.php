<?php
	$tpl = new raintpl();
	$tpl->assign("news_list", $array);
	$tpl->assign("isMobile", isMobile());
	draw( $tpl->draw("page_intro", $return_string=true), 'Accueil');
?>
