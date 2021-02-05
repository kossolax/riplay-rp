<style type="text/css">
	.form-horizontal
	{
		border : white solid 2px;
		color : white;
	}
</style>


<div id="creation"> 
	<h2>Création d'un ticket</h2>
	<form class="form-horizontal">
<fieldset>
<div class="form-group">
  <label  class="col-md-2 control-label" for="textinput">Pseudo :</label>  
  <div class="col-md-2 col-md-offset-1">
  <input id="textinput" name="textinput" placeholder="Votre Pseudo" class="form-control input-md" type="text">
    
  </div>
</div>

<!-- Multiple Radios -->
<div class="form-group">
  <label  class="col-md-2 control-label" for="radios">Catégorie :</label>
  <div class="col-md-2 ">
  <div class="radio">
    <label for="radios-0">
      <input name="radios" id="radios-0" value="1" checked="checked" type="radio">
      Bug 
    </label>
	</div>
  <div class="radio">
    <label for="radios-1">
      <input name="radios" id="radios-1" value="2" type="radio">
      Crash
    </label>
	</div>
  <div class="radio">
    <label for="radios-2">
      <input name="radios" id="radios-2" value="3" type="radio">
      Forum
    </label>
	</div>
  <div class="radio">
    <label for="radios-3">
      <input name="radios" id="radios-3" value="4" type="radio">
      Map 
    </label>
	</div>
  <div class="radio">
    <label for="radios-4">
      <input name="radios" id="radios-4" value="5" type="radio">
      Job 
    </label>
	</div>
  <div class="radio">
    <label for="radios-5">
      <input name="radios" id="radios-5" value="6" type="radio">
      Item
    </label>
	</div>
  </div>
</div>

<!-- Textarea -->
<div class="form-group">
  <label  class="col-md-2 control-label" for="textarea">Descriptif :</label>
 <div class="col-md-2">                   
    <textarea class="form-control" id="textarea" name="textarea">Motif du ticket</textarea>
  </div>
</div>

<!-- Text input-->
<div class="form-group">
  <label class="col-md-2 control-label" for="textinput2">Lien : </label>  
  <div class="col-md-2">
  <input id="textinput2" name="textinput2" placeholder="lien vers page forum" class="form-control input-md" type="text">
    
  </div>
</div>

<!-- Button -->
<div class="form-group">
  <label  class="col-md-2" for="singlebutton"></label>
  <div class="col-md-2">
    <button id="singlebutton" name="singlebutton" class="btn btn-success">Envoyer</button>
  </div>
</div>

</fieldset>
</form>


</div>
<div id="attentevalid">
	<h2>En attente de validation</h2>
</div>
<div id="attenteprogra">
	<h2>En attente de programmation</h2>
</div>
<div id="enprogra">
	<h2>En cours de programmation</h2>
</div>
<div id="terminé">
	<h2>Récement terminé</h2>
</div>
