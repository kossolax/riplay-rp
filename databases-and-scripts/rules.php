<style>
* {
	background:black !important;
	color:white;;
}
.noPyjCat_1 {
	color:#AAAAFF;
}
.noPyjCat_2 {
        color:#FFAAAA;
}
.noPyjCat_2.5 {
        color:#FFFFAA;
}
.noPyjCat_3 {
        color:#AAFFAA;
}
.noPyjCat_3\.5 {
        color:#FFAAFF;
}
.noPyjCat_4 {
        color:#AAFFFF;
}


</style>
<?php
	$arr = array( "1" => "NOPYJ", "2" => "POLICE", "2.5" => "PVP", "3" => "JUSTICE", "3.5" => "CODEPENAL", "4" => "VRAC" );

	include_once('config.inc.php');
	
	mysql_query("ALTER TABLE `site_nopyj_reponses` ORDER BY `id`;");
	mysql_query("ALTER TABLE `site_nopyj_question` ORDER BY `id`;");

	if( $_GET['action'] == "addQuestion" ) {
		$update = false;
		if( isset($_POST['id']) ) {
			$update = true;
			$id = intval($_POST['id']);			
			$query = "SELECT Q.id, Q.question, Q.categorie, R1.id as id1, R2.id as id2, R3.id as id3, R4.id as id4 FROM `site_nopyj_question` as Q";
			$query .= "	INNER JOIN `site_nopyj_reponses` as R1 on Q.`id`=R1.`idQuestion`";
			$query .= "     INNER JOIN `site_nopyj_reponses` as R2 on Q.`id`=R2.`idQuestion`";
			$query .= "     INNER JOIN `site_nopyj_reponses` as R3 on Q.`id`=R3.`idQuestion`";
			$query .= "     INNER JOIN `site_nopyj_reponses` as R4 on Q.`id`=R4.`idQuestion`";
			$query .= "	WHERE Q.`id`='".$id."' AND R2.id<>R1.id AND R3.id<>R1.id AND R3.id<>R2.id AND R4.id<>R1.id AND R4.id<>R2.id AND R4.id<>R3.id";
			$qID = mysql_fetch_array(mysql_query($query));			
			mysql_query("UPDATE `site_nopyj_question` SET `question` = '".mysql_real_escape_string($_POST['question'])."' WHERE id = '".$id."';");
			mysql_query("UPDATE `site_nopyj_reponses` SET `reponse` = '".mysql_real_escape_string($_POST['rep1'])."' WHERE id = '".$qID['id1']."';");
			mysql_query("UPDATE `site_nopyj_reponses` SET `reponse` = '".mysql_real_escape_string($_POST['rep2'])."' WHERE id = '".$qID['id2']."';");
			mysql_query("UPDATE `site_nopyj_reponses` SET `reponse` = '".mysql_real_escape_string($_POST['rep3'])."' WHERE id = '".$qID['id3']."';");
			mysql_query("UPDATE `site_nopyj_reponses` SET `reponse` = '".mysql_real_escape_string($_POST['rep4'])."' WHERE id = '".$qID['id4']."';");
		}
		if ($update == false) {
			mysql_query("INSERT INTO `site_nopyj_question` (`id`, `question`, `categorie`) VALUES (NULL, '".mysql_real_escape_string($_POST['question'])."', '".mysql_real_escape_string($_POST['categorie'])."');");
			$val = mysql_insert_id();
			mysql_query("INSERT INTO `site_nopyj_reponses` (`id`, `idQuestion`, `reponse`, `estVraie`) VALUES (NULL, '".$val."', '".mysql_real_escape_string($_POST['rep1'])."', '1');");
			mysql_query("INSERT INTO `site_nopyj_reponses` (`id`, `idQuestion`, `reponse`, `estVraie`) VALUES (NULL, '".$val."', '".mysql_real_escape_string($_POST['rep2'])."', '0');");
			mysql_query("INSERT INTO `site_nopyj_reponses` (`id`, `idQuestion`, `reponse`, `estVraie`) VALUES (NULL, '".$val."', '".mysql_real_escape_string($_POST['rep3'])."', '0');");
			mysql_query("INSERT INTO `site_nopyj_reponses` (`id`, `idQuestion`, `reponse`, `estVraie`) VALUES (NULL, '".$val."', '".mysql_real_escape_string($_POST['rep4'])."', '0');");
		}
		header("Location: index.php");
		exit();
	}
?>
<div style='float:left;'>
	<h2>Liste des questions</h2>
<ul>
<?php
	$data = mysql_query("SELECT * FROM site_nopyj_question ORDER BY `categorie`,`id`;");
	while($row = mysql_fetch_array($data) ) {
		echo "<li>[".$arr[$row['categorie']]."] <a class='noPyjCat_".$row['categorie']."' href='index.php?action=view&id=".$row['id']."'>".$row['question']."</a></li>";
	}

	if( $_GET['action'] == "view" ) {
		$id = intval($_GET['id']);
		$query = "SELECT Q.id, Q.question, Q.categorie, R1.reponse as rep1, R2.reponse as rep2, R3.reponse as rep3, R4.reponse as rep4 FROM `site_nopyj_question` as Q";
		$query .= "	INNER JOIN `site_nopyj_reponses` as R1 on Q.`id`=R1.`idQuestion`";
		$query .= "     INNER JOIN `site_nopyj_reponses` as R2 on Q.`id`=R2.`idQuestion`";
		$query .= "     INNER JOIN `site_nopyj_reponses` as R3 on Q.`id`=R3.`idQuestion`";
		$query .= "     INNER JOIN `site_nopyj_reponses` as R4 on Q.`id`=R4.`idQuestion`";
		$query .= "	WHERE Q.`id`='".$id."' AND R2.id<>R1.id AND R3.id<>R1.id AND R3.id<>R2.id AND R4.id<>R1.id AND R4.id<>R2.id AND R4.id<>R3.id";
		$qID = mysql_fetch_array(mysql_query($query));
	}
?>
</ul>
</div>
<div style='float:right;'>
	<h2>Ajouter une question:</h2>
	<form method="POST" action="index.php?action=addQuestion">
		Question: <input type="text" size="80" name="question" value="<?php echo $qID['question'];?>" /><br />
		Bonne réponse:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <input type="text" size="60" name="rep1"  value="<?php echo $qID['rep1'];?>" /><br />
		Mauvaise réponse: <input type="text" size="60" name="rep2" value="<?php echo $qID['rep2'];?>" /><br />
		Mauvaise réponse: <input type="text" size="60" name="rep3" value="<?php echo $qID['rep3'];?>" /><br />
		Mauvaise réponse: <input type="text" size="60" name="rep4" value="<?php echo $qID['rep4'];?>" /><br />
<?php
	if( $_GET['action'] == "view" ) {
		echo '<input type="hidden" name="categorie" value="'.$qID['categorie'].'" />';
		echo '<input type="hidden" name="id" value="'.$qID['id'].'" />';
		echo '<input type="submit" value="Modifier" />';

		echo '<br /><br /> Ou <a href="index.php">ajouter une autre question</a>';
	}
	else {
?>
		ATTENTION A PAS SE TROMPER ICI:
		<select name="categorie">
                        <option value="1">Règlement Général</option>
                        <option value="2">Règlement Police</option>
                        <option value="2.5">Règlement PvP</option>
                        <option value="3">Règlement Justice</option>
                        <option value="3.5">Code Pénal</option>
                        <option value="4">En vrac</option>
                </select>

		<input type="submit" value="Envoyer" />
<?php
	}
?>
	</form>
</div>
