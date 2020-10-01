<?php
				$tpl = new raintpl();
				$tpl->assign('steamid', str_replace("STEAM_0", "STEAM_1",$user->data['steamid']));
				$tpl->assign("test", encode("salut", "yo"));
				draw($tpl->draw("panel/index", $return_string=true), "Panel: Accueil");
?>
