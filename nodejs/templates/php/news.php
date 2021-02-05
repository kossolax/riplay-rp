<?php
	$_PARSE = array();
//	mysql_query("SET NAMES UTF8");

	if( isset($_GET['id']) ) {
		$data = mysql_fetch_array(mysql_query("SELECT * FROM `site_news` WHERE `id`='".intval($_GET['id'])."' LIMIT 1;"));
	}
	else {
		$data = mysql_fetch_array(mysql_query("SELECT * FROM `site_news` ORDER BY `id` DESC LIMIT 1;"));
	}
	$_PARSE = $data;
	$_PARSE['larger'] = $data['size_larger'];

	$txt = "";
	$query = mysql_query("SELECT * FROM `site_news` ORDER BY `id` DESC LIMIT 10;");
	while( $row = mysql_fetch_array($query) ) {
		$row['content'] = _substr(strip_tags($row['content']), 130);
		$row['titre'] = _substr(strip_tags($row['titre']), 50);

		if( isset($row['id_forum']) && $row['id_forum'] > 0 ) {
			$row2 = mysql_fetch_array(mysql_query("SELECT * FROM `phpbb3_posts` WHERE `post_id`='".$row['id_forum']."' LIMIT 1;"));

			$post_text = $row2['post_text'];
			$bbcode = new bbcode(base64_encode($bbcode_bitfield));
			$bbcode->bbcode_second_pass($post_text, $row2['bbcode_uid'], $row2['bbcode_bitfield']);
			$post_text = smiley_text($post_text);
			$post_text = nl2br( $post_text );

			if( strlen($post_text) > 1 ) {
				$row['content'] = _substr(strip_tags($post_text), 130);
			}
			$row['time'] = $row2['post_time'];
			$row['titre'] = _substr(strip_tags($row2['post_subject']), 50);
			$row['poster'] = $row2['username'];
		}

		$txt .= parsetemplate( gettemplate('row_news'), $row);
	}
	$_PARSE['news_row'] = $txt;

	if( isset($data['id_forum']) && $data['id_forum'] > 0 ) {
		$row = mysql_fetch_array(mysql_query("SELECT * FROM `phpbb3_posts`, `phpbb3_users` WHERE `post_id`='".$data['id_forum']."' AND `phpbb3_posts`.`poster_id` = `phpbb3_users`.`user_id` LIMIT 1;"));

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

		$_PARSE['time'] = $row['post_time'];
		$_PARSE['titre'] = $row['post_subject'];
		$_PARSE['poster'] = $row['username'];
	}
	display( parsetemplate( gettemplate('page_news'), $_PARSE), 'Accueil', 'News', 'location_site');
?>
