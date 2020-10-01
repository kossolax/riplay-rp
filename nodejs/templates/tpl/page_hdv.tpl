<style>
.thumbnail {
	height:110px;
	overflow:hidden;
	margin:1px;
	cursor:pointer;
	background-color:#222;
}
.thumbnail:hover {
	border-color:#33f;
	background-color:#333;
}
.tb2 .caption {
	padding-top:0px !important;
	padding-bottom:0px !important;
}
.thumbnail img.caption {
	width:80%;
}
</style>
<div class="row">
	<h2>H&ocirc;tel des ventes</h2>

	<ul class="nav nav-tabs">
		<li><a href="" onclick='location.reload(true); return false;'>{$argent}$</a></li>
		<li {if="$ACTION==item"}class="active"{/if}><a href="index.php?page=hdv&action=item">Inventaire</a></li>
		<li {if="$ACTION==selling"}class="active"{/if}><a href="index.php?page=hdv&action=selling">Ventes</a></li>
		<li {if="$ACTION==buy"}class="active"{/if}><a href="index.php?page=hdv&action=buy">Achats</a></li>
	</ul>

	<div class="tabbable tabs-left" style="width:105px; float:left;">
		<ul class="nav nav-pills nav-stacked nav-tabs" style="margin-top:3px;">
			{$a=0}
			{loop="jobs"}{if="!in_array($key, $denied) && ($byJob[$key]|count) != 0"}
					<li {if="$a==0"}class="active"{/if}><a href="#toggle-job-{$key}">{$key|pretty_job} ({$byJob[$key1]|count})</a></li>
					{$a=$a+1}
			{/if}{/loop}
			{if="$ACTION==selling"}
				<li class="active"><a href="#toggle-log-doing">En cours</a></li>
				<li><a href="#toggle-log-done">Termin&eacute;e</a></li>
			{/if}
			{if="$ACTION==idle"}
				<li><a href="#">&nbsp;</a></li>
			{/if}
		</ul>
	</div>
	<div class="tab-content col-sm-9" style="height:100%;">
	{if="$ACTION==item"}
		{$a=0}
		{loop="jobs"}{if="!in_array($key, $denied) && ($byJob[$key]|count) != 0"}
			<div class="tab-pane row {if="$a==0"}active{/if}" id="toggle-job-{$key}">
				{$a=$a+1}
				{loop="items"}{if="$value.job_id==$key1 && $allItems[$key2]"}
					<div class="col-sm-2">
						<div class="thumbnail tb2" data-taxe="{$value.taxe}" data-price="{$value.prix}" data-amount="{$allItems[$key2]}" data-id="{$key2}">
							<div class="caption">
							<h3><i>{$allItems[$key2]}x</i> <strong>{$value.nom}</strong></h3>
						</div>
						<img src="/images/roleplay/csgo/items/{$key2}.png" width="60" height="60" />
						</div>
					</div>
				{/if}{/loop}
			</div>
		{/if}{/loop}
	{elseif="$ACTION==selling"}
		<div class="tab-pane row active" id="toggle-log-doing">
			{loop="allItems"}{if="$value.done==0"}
			<div class="col-sm-6">
				<div class="thumbnail" data-taxe="{$items[$value.itemID]['taxe']}" data-price="{$value.price}" data-amount="{$value.amount}" data-id="{$value.id}" data-name="{$items[$value.itemID]['nom']}">
					<div class="col-sm-3">
						<img src="/images/roleplay/csgo/items/{$value.itemID}.png" class="caption" />
					</div>
					<div class="col-sm-9">
						<h3>
							<strong>Nom:</strong> {$items[$value.itemID]['nom']} <br />
							<strong>Prix unit&eacute;</strong>: {$value.price}$<br />
							<strong>Quantit&eacute;</strong>: {$value.amount}<br /><br />
							<strong>Prix HTVA:</strong> {function="pretty_number(($value.price*$value.amount)-(($value.price*$value.amount)/100.0*$items[$value.itemID]['taxe']) )"}$<br />
							<strong>Prix TVA<i>(+{$items[$value.itemID]['taxe']}%)</i>:</strong> {function="pretty_number($value.price*$value.amount)"} $
						</h3>
					</div>
				</div>
			</div>
			{/if}{/loop}
		</div>
		<div class="tab-pane row" id="toggle-log-done">
			{loop="allItems"}{if="$value.done==1"}
			<div class="col-sm-6">
				<div class="thumbnail" disabled="disabled">
					<div class="col-sm-3">
						<img src="/images/roleplay/csgo/items/{$value.itemID}.png" class="caption" />
					</div>
					<div class="col-sm-9">
						<h3>
							<strong>Nom:</strong> {$items[$value.itemID]['nom']} <br />
							<strong>Prix unit&eacute;</strong>: {$value.price}$<br />
							<strong>Quantit&eacute;</strong>: {$value.amount}<br /><br />
							<strong>Prix HTVA:</strong>{function="pretty_number(($value.price*$value.amount)-(($value.price*$value.amount)/100.0*$items[$value.itemID]['taxe']) )"}$ <br />
							<strong>Prix TVA<i>(+{$items[$value.itemID]['taxe']}%)</i>:</strong>{function="pretty_number($value.price*$value.amount)"} $
						</h3>
					</div>
				</div>
			</div>
			{/if}{/loop}
		</div>
        {elseif="$ACTION==buy"}
                {$a=0}
		{loop="jobs"}{if="!in_array($key, $denied)"}
			<div class="tab-pane row {if="$a==0"}active{/if}" id="toggle-job-{$key}">
			{$a=$a+1}
			{loop="allItems"}{if="$items[$value.itemID]['job_id'] == $key1"}
				<div class="col-sm-6">
				<div class="thumbnail"  data-taxe="{$items[$value.itemID]['taxe']}" data-price="{$value.price}" data-amount="{$value.amount}" data-id="{$value.id}" data-name="{$items[$value.itemID]['nom']}" >
					<div class="col-sm-3">
						<img src="/images/roleplay/csgo/items/{$value.itemID}.png" class="caption" /> 
					</div>
					<div class="col-sm-9">
						<h3>
							<strong>Nom:</strong> {$items[$value.itemID]['nom']} <br />
							<strong>Prix unit&eacute;</strong>: {$value.price}$<br />
							<strong>Quantit&eacute;</strong>: {$value.amount}<br /><br />
							<strong>Prix HTVA:</strong> {function="pretty_number(($value.price*$value.amount)-(($value.price*$value.amount)/100.0*$items[$value.itemID]['taxe']) )"}$ <br />
							<strong>Prix TVA<i>(+{$items[$value.itemID]['taxe']}%)</i>:</strong> {function="pretty_number($value.price*$value.amount)"}$
						</h3>
					</div>
				</div>
				</div>
			{/if}{/loop}
			</div>
		{/if}{/loop}
	{elseif="$ACTION==idle"}
		<br /><br />
		{if="$ERR"}<div class="col-sm-5 col-sm-offset-3 alert alert-danger" role="alert">{$ERR}</div><br clear="all"/><br />{/if}
		<p class="text-center">
			<br />
			Chargement des donn&eacute;es... Veuillez patienter quelques instants <br />
			<img src="/images/bar-loading.gif" />
			<script type="text/javascript">
				$(document).ready( function() {
					setTimeout( function() {
						location.href = "/index.php?page=hdv&action=item";
					}, {if="$ERR"}5{else}1{/if}000);
				});
			</script>
			<br /><br />
		</p>
	{/if}
	</div>
</div>
<div class="modal fade" id="myModal">
	<div class="modal-dialog">
		<div class="modal-content">
			<form class="form-horizontal" method="POST" action="index.php?page=hdv&action={$ACTION}">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
				<h4 class="text-info modal-title">D&eacute;poser dans l'h&ocirc;tel des ventes:</h4>
			</div>
			<div class="modal-body row">
				<div class="col-sm-4">
					<h3 class="text-info"></h3>
					<img src="#" class="col-sm-12" />
				</div>
				<div class="col-sm-8">
					<div class="row">
						<label class="col-sm-4 control-label" for="amount">Quantit&eacute;:&nbsp;</label>
						<div class="col-sm-6">
							<input id="amount" name="amount" type="number" max="1000" min="1" class="form-control" value="1" />
						</div>
					</div>
					<div class="row">
						<label class="col-sm-4 control-label" for="price">Prix/unit&eacute;:&nbsp;</label>
						<div class="col-sm-6">
							<input id="price" name="price" type="number" max="1000" min="1" class="form-control" value="1" />
						</div>
					</div>
					<hr />
					<div class="row">
						<label class="col-sm-4 control-label" for="price">Total HTVA:&nbsp;</label>
						<div class="col-sm-6">
							<input id="total2" type="number" class="form-control" disabled="disabled" value="lol" />
						</div>
					</div>
					<div class="row">
                                                <label class="col-sm-4 control-label" for="price">Total TVA* +<span id="taxe"></span>%:&nbsp;</label>
                                                <div class="col-sm-6">
                                                        <input id="total" type="number" class="form-control" disabled="disabled" value="lol" />
                                                </div>

						<input type="hidden" name="item" value="0" id="itemID" />
                                        </div>
				</div>
			</div>
			<div class="modal-footer clearfix">
				<div class="col-sm-6 text-left">
					*La TVA est une taxe envoy&eacute;e dans le capital du job ayant vendu l'objet concern&eacute;.
				</div>
				<div class="col-sm-6">
					{if="$ACTION==item"}
						<input type="submit" class="btn btn-default" name="action" value="R&eacute;cup&eacute;rer" onclick="disableButton(this);" />
					{/if}
					<button type="button" class="btn btn-default btn-warning" data-dismiss="modal">Annuler</button>
					{if="$ACTION==item"}
						<input type="submit" class="btn btn-default btn-success" name="action" value="Vendre" onclick="disableButton(this);" />
					{elseif="$ACTION==selling"}
						<input type="submit" class="btn btn-default btn-success" name="action" value="R&eacute;cup&eacute;rer" onclick="disableButton(this);" />
					{elseif="$ACTION==buy"}
						<input type="submit" class="btn btn-default btn-success" name="action" value="Acheter" onclick="disableButton(this);" />
					{/if}
				</div>
			</div>
			</form>
		</div>
	</div>
</div>

<script type="text/javascript">
	$("#price, #amount").change( function() {
		updateTotal();
	});
	function updateTotal() {

		if( $("#amount").attr('disabled') !== 'disabled' ) {

			if( parseInt($("#amount").val()) > parseInt($("#amount").attr('max')) )
				$("#amount").val( $("#amount").attr('max') );
			if( parseInt($("#amount").val()) < parseInt($("#amount").attr('min')) )
				$("#amount").val( $("#amount").attr('min') );

			if( parseInt($("#price").val()) < parseInt($("#price").attr('min')) )
				$("#price").val( $("#price").attr('min') );

			if( parseInt($("#price").val()) > parseInt($("#price").attr('max')) )
				$("#price").val( $("#price").attr('max') );
		}

		$("#total").val( $("#price").val() * $("#amount").val() );
		$("#total2").val( Math.round($("#total").val() - ($("#total").val()/100*$("#taxe").text())) );
	}
	$(document).ready( function() {
		var hash = window.location.hash;
		if( hash ) {
			 $('ul.nav a[href="' + hash + '"]').tab('show');
			window.location.hash = window.location.hash;
		}

		$('.nav-tabs a').click(function (e) {
			$(this).tab('show');
			var scrollmem = $('body').scrollTop();
			window.location.hash = this.hash;
			$('html,body').scrollTop(scrollmem);
			return false;
		});

		$(".thumbnail").click( function() {
			if( $(this).attr('disabled') === 'disabled' )
				return;
	
			{if="$ACTION==item"}
				disposit(this);
			{elseif="$ACTION==selling"}
				withdraw(this, "Vos items dans l'HDV");
			{elseif="$ACTION==buy"}
				withdraw(this, "Acheter dans l'HDV");
			{/if}
		});

	});
	function withdraw(that, title) {
                var maxAmount = $(that).attr("data-amount");

                $('#myModal').find("#amount").val( $(that).attr("data-amount") );
                $('#myModal').find("#price").val( $(that).attr("data-price") );
                $('#myModal').find("#taxe").html( $(that).attr("data-taxe") );
                $('#myModal').find("#itemID").val( $(that).attr("data-id") );
		$('#myModal').find("h3").text( $(that).attr("data-name") );

		$('#myModal').find("#amount").attr("disabled", "disabled");
		$('#myModal').find("#price").attr("disabled", "disabled");

                updateTotal();

                $('#myModal').find("img").attr( "src", $(that).find("img").attr("src") );
		$('#myModal').find(".modal-title").html(title);
                $('#myModal').modal('show');
	}
	function disposit(that) {
		var maxAmount = $(that).attr("data-amount");
		if( maxAmount > 1000 )
			maxAmount = 1000;


		$('#myModal').find("#amount").attr('disabled', 'disabled');
		$('#myModal').find("#amount").attr("min", "1");
		$('#myModal').find("#amount").attr("max", ""+maxAmount);
		
		maxAmount = $(that).attr("data-price");

		$('#myModal').find("#price").attr("max", ""+(maxAmount*4));
		$('#myModal').find("#price").attr("min", ""+ Math.ceil(maxAmount/4));
		$('#myModal').find("#price").attr("value", $(that).attr("data-price") );

		$('#myModal').find("#taxe").html( $(that).attr("data-taxe") );
		$('#myModal').find("#itemID").val( $(that).attr("data-id") );


		updateTotal();

		$('#myModal').find("#amount").removeAttr("disabled");

		$('#myModal').find("h3").text( $(that).find("h3").text() );
		$('#myModal').find("img").attr( "src", $(that).find("img").attr("src") );
		$('#myModal').modal('show');
	
	};
	 function disableButton(button) {
		button.disabled = true;
		$(button).parent().prepend("<input type='hidden' name='action' value='"+button.value+"' />");
		button.form.submit();
	}
</script>
