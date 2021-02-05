	<div class="row">
		<br />
                <div class="alert alert-dismissable alert-danger">
                        <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
                        <h4>Attention</h4>
			Cette messagerie est toujours en construction. Certainne fonctionnalit&eacute; ne sont pas encore disponible.
			La messagerie est gratuite dans sa version BETA.<br />

			Les plaintes police se font maintenant via cette page! Envoyez un message &agrave; "Plainte contre le policier", suivit du nom du policier.
			Exemple, pour vous plaindre de "kossolax":	<img src="http://image.noelshack.com/fichiers/2015/10/1425646345-capture.png" height="40" />
          </div>
		<h2 class="clearfix">Messagerie</h2>
	</div>
	<div class="row">
		<div class="tabbable tabs-left">
			<ul class="nav nav-pills nav-stacked nav-tabs">
				<li><a href="#new" data-toggle="tab">Nouveau</a></li>
				<li class="{if="!$showMsg"}active{/if}"><a href="#inbox" data-toggle="tab"><span class="badge pull-right">{$count}</span> Re&ccedil;u </a></li>
				<li><a href="#outbox" data-toggle="tab"> Envoy&eacute; </a>
			</ul>
		</div>
		<div class="tab-content col-md-9" style="background:none; border:none;">
			<div class="tab-pane row" id="new">
				<h2> Envoyer un nouveau message </h2>
				<form method="post" class="form-horizontal">
					<fieldset>
						<div class="form-group">
							<label class="col-md-1 control-label" for="sendTo">Envoyer &agrave;</label>
							<div class="col-md-10" id="remote">
								<input name="sendTo" id="sendMe" type="hidden" />
								<div class="input-group">
									<span class="input-group-addon" id="sendName"></span>
									<input id="sendTo" type="text" placeholder="pseudo" class="form-control typeahead" data-role="tagsinput">
								</div>
    							</div>
						</div>
						<div class="form-group">
							<label class="col-md-1 control-label" for="title">Titre:</label>  
							<div class="col-md-10">
								<input id="title" name="title" type="text" class="form-control" required="required" maxlength="140">
    							</div>
						</div>
						<div class="form-group">
							<label class="col-md-1 control-label" for="msg">Message:</label>
							<div class="col-md-10">                     
								<textarea class="form-control" id="msg" name="msg" required="required" rows="6" maxlength="2048"></textarea>
							</div>
						</div>
						<div class="form-group">
							<label class="col-md-1 control-label" for="ssend"></label>
							<div class="col-md-2 col-md-offset-9">
								<input type="submit" id="ssend" class="btn btn-primary" value="Envoyer" />
							</div>
						</div>
					</fieldset>
				</form>
			</div>
			<div class="tab-pane {if="!$showMsg"}active{/if} row" id="inbox">
				<br />
				<div class="list-group">
				{loop="inbox"}
	                                <a href="/index.php?page=phone&viewID={$value.id}" class="list-group-item {if="$value.seen == 0"}active{/if}">
	       					<span class="name">De {$value.name}</span>
                                               	<strong>{$value.title}</strong>
                                                <span class="text-muted">{$value.text}</span>
                                                <span class="badge">{$value.timestamp|prettytime}</span>
                                        </a>
                                {/loop}
				{if="!$inbox"}<h3>Pas de message.</h3>{/if}
				</div>
			</div>
			<div class="tab-pane row" id="outbox">
				<br />
				<div class="list-group">
                                        {loop="outbox"}
                                        <a href="/index.php?page=phone&viewID={$value.id}" class="list-group-item {if="$value.seen == 0"}active{/if}">
                                                <span class="name">&agrave; {$value.targetName} </span>
                                                <strong>{$value.title}</strong>
                                                <span class="text-muted">{$value.text}</span>
                                                <span class="badge">{$value.timestamp|prettytime}</span>
                                        </a>
                                        {/loop}
				{if="!$outbox"}<h3>Pas de message.</h3>{/if}
				</div>
			</div>
			<div class="tab-pane row {if="$showMsg"}active{/if}" id="showMSG">
				<br />
				<div class="list-group">
					<div class="list-group-item well">
                                        <form method="post" class="form-horizontal">
						<legend>R&eacute;pondre: &agrave {$parti}: </legend>
						{loop="police"}{if="strpos($value,STEAM_1)!==false"}
							<a href="#" onclick="window.open('/index.php?page=tribunal&action=case&steamid={$value}');" class="btn btn-warning">Tribunal</a>
						{/if}{/loop}
                                                <fieldset>
                                                        <input type="hidden" name="message_id" value="{$origin}" />
                                                        <div class="form-group">
                                                                <div class="col-md-10 col-md-offset-1">
                                                                        <textarea class="form-control" id="msg" name="msg" required="required" rows="6" maxlength="2048"></textarea>
                                                                </div>
							</div>
							<div class="form-group">
                                                                <div class="col-md-2 col-md-offset-9">
                                                                        <input type="submit" id="ssend" class="btn btn-primary" value="R&eacute;pondre" />
                                                                </div>
                                                        </div>
                                                </fieldset>
                                        </form>
					</div>

					{loop="showMsg"}
					<div class="list-group-item well {if="$value.seen == 0"}active{/if}">
					<span class="name">De {$value.name} &agrave; {$value.targetName}</span>: - 
					<strong>{$value.title}</strong><br /><br />
					<span>{$value.text}</span>
					<span class="badge">{$value.timestamp|prettytime}</span>
					</div>
					{/loop}
				</div>
			</div>
		</div>
        </div>

<script type="text/javascript">
var seed = new Bloodhound({
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('steamid'),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
	prefetch: '/cache/phone.json?v=6',
        remote: 'index.php?page=phone&search=%QUERY'
});

seed.initialize();

$('#remote .typeahead').typeahead({
        hint: true,
        highlight: true,
        minLength: 1
}, {
        name: 'search-engine',
        displayKey: function(data) {
                return data.name + " - " + data.job;
        },
        source: seed.ttAdapter()
}).on('typeahead:selected', function(event, data){
        $('#sendMe').val($('#sendMe').val()+data.steamid+",");
        setTimeout( function() { $('.typeahead').val(""); }, 10);

        var html = document.createElement("span");
        html.innerHTML = data.name;
        html.title = data.steamid;
        html.className = "badge";
        html.style.cursor = "pointer";

        html.onclick = function() {
                var title = this.title + ",";
                var data = $('#sendMe').val();
                data = data.replace(title, "");
                $('#sendMe').val(data);

                this.parentElement.removeChild(this);
        };

        $('#sendName').append(html);
}).on('typeahead:closed', function( event, data) {
        $('.typeahead').val("");
        setTimeout( function() { $('.typeahead').val(""); }, 10);

});
</script>

