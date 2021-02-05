<div class="center block-800">

<form method="POST" action="admin.php?page=email&action=sent" id="send_mail">
        Titre: <input type="text" class="inputText" style="width:465px;" name="subject"/>
        Destinataire: <input type="text" class="inputText" style="width:200px;" name="email"/><br />
        <textarea class="wysiwyg" name="message"></textarea>
        <div id="UploadButton" class="right" onclick="jQuery('#send_mail').submit(); return false;"> Envoyer </div>
<form>

</div>
<br /><br />
