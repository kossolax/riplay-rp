<?php
function str_replace_last( $search , $replace , $str ) {
    if( ( $pos = strrpos( $str , $search ) ) !== false ) {
        $search_length  = strlen( $search );
        $str    = substr_replace( $str , $replace , $pos , $search_length );
    }
    return $str;
}

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

	if( isset($data['id_forum']) && $data['id_forum'] > 0 ) {
		$row = mysql_fetch_array(mysql_query("SELECT * FROM `phpbb3_posts`, `phpbb3_users` WHERE `post_id`='".$data['id_forum']."' AND `phpbb3_posts`.`poster_id` = `phpbb3_users`.`user_id` LIMIT 1;"));

		$post_text = $row['post_text'];

		$bbcode = new bbcode(base64_encode($bbcode_bitfield));
		$bbcode->bbcode_second_pass($post_text, $row['bbcode_uid'], $row['bbcode_bitfield']);
		$post_text = bbcode_nl2br($post_text);

		$post_text = smiley_text($post_text);
		$post_text =  censor_text($post_text);

		$post_text = str_replace("<table>", '<div class="col-md-12 column">', $post_text);
		$post_text = str_replace("</table>", "</div>", $post_text);

		$post_text = str_replace("<tr>", '<div class="row clearfix">', $post_text);
		$post_text = str_replace("</tr>", "</div>", $post_text);

		$post_text = str_replace('<td width="650" style="vertical-align:top;">', '<div class="col-md-8 column">', $post_text);
		$post_text = str_replace('<td width="350" style="vertical-align:top;">', '<div class="col-md-4 column">', $post_text);
		$post_text = str_replace('</td><div class="col-md-4 column">', '</div><div class="col-md-4 column">', $post_text);
		$post_text = str_replace_last("</td>", "</div>", $post_text);

		if( strlen($post_text) > 1 ) {
			$_PARSE['content'] = $post_text."<br /><br />";
			mysql_query("UPDATE `phpbb3_topics` SET `topic_views`=`topic_views`+1 WHERE `topic_id`='".$row['topic_id']."' LIMIT 1;");
		}


		$_PARSE['time'] = $row['post_time'];
		$_PARSE['titre'] = $row['post_subject'];
		$_PARSE['poster'] = $row['username'];
	}
	display( parsetemplate( gettemplate('page_news_v2'), $_PARSE), 'Accueil', 'News', 'location_site');
?>
