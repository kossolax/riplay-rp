<?php
	$_PARSE = array();
	if( isset($_GET['p']) ) {
		$row = mysql_fetch_array(mysql_query("SELECT * FROM `phpbb3_posts` INNER JOIN `phpbb3_users` ON `phpbb3_posts`.`poster_id` = `phpbb3_users`.`user_id` WHERE `post_id`='".intval($_GET['p'])."' LIMIT 1;"));

		$post_text = $row['post_text'];

		$bbcode = new bbcode(base64_encode($bbcode_bitfield));
		$bbcode->bbcode_second_pass($post_text, $row['bbcode_uid'], $row['bbcode_bitfield']);
		$post_text = bbcode_nl2br($post_text);

		$post_text = smiley_text($post_text);
		$post_text =  censor_text($post_text);

		if( strlen($post_text) > 1 ) {
			$_PARSE['content'] = $post_text."<br /><br />";
			mysql_query("UPDATE `phpbb3_topics` SET `topic_views`=`topic_views`+1 WHERE `topic_id`='".$row['topic_id']."' LIMIT 1;");
		}

		$_PARSE['titre'] = utf8_encode($row['post_subject']);
		$_PARSE['poster'] = $row['username'];
		$_PARSE['content'] = utf8_encode($post_text);
	}
	display( parsetemplate( gettemplate('page_viewpost'), $_PARSE), 'Accueil', 'News', 'location_site');
?>
