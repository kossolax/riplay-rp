<h2> Le tribunal: Etude du cas de: {$nom} </h2>

<div class="col-md-12">
	<div class="row"  data-toggle="tooltip" data-original-title="Réfléchissez avant de confirmer votre vote, les boutons seront débloqués dans quelques instants">
		<div class="col-md-2">
			<ul>
				<li>Nom connu:
					<select style="width:150px;">
						<option>{$nom}</option>
						{loop="$case.list_pseudo"}
							{if="strlen($value)>2"}
								<option>{$value}</option>
							{/if}
						{/loop}
					</select>
				</li>
				<li>Job: {$job}</li>
				{if="$nopyj"}
				<li class="text-warning">Possède le nopyj</li>
				{/if}
				<li>Argent possédé: {$money|pretty_number}$</li>
			</ul>
		</div>
		<div class="col-md-2">
			<ul>
				<li>Temps de jeu: {$case.time_played}H</li>
				<li {if="$case.killed>$case.died"}class="text-warning"{/if}>Meurtre: {$case.killed}</li>
				<li {if="$case.killed<$case.died"}class="text-success"{/if}>Décês: {$case.died}</li>
				<li>Prison: {$case.got_jail|pretty_number|count}</li>
				<li>Argent donné: {$case.give_money_amount|pretty_number}</li>
				<li>Argent reçu: {$case.takken_money_amount|pretty_number}</li>				
			</ul>
		</div>
		<div class="col-md-3">
			<ul>
				{loop="$case.list_rapport"}<li>{$value}</li>{/loop}
			</ul>
		</div>
		<div class="col-md-3 text-center">
			<form action="index.php?page=tribunal&action=vote" method="post">
				<input type="hidden" name="steamid" value="{$steamid_encoded}" />
				
				<div id="recaptch"></div>
				
				<input type="hidden" name="value" value="-1" id="voteValue" />
				
				<input type="submit" onclick="$('#voteValue').val(1)" value="Condamner" class="btn btn-danger disabled" />
				<input type="submit" onclick="$('#voteValue').val(2)" value="Ignorer" class="btn btn-warning" />
				<input type="submit" onclick="$('#voteValue').val(0)" value="Acquitter" class="btn btn-success disabled"/>
				
			</form>
			
			{$case.vote.condamner/($case.vote.condamner+$case.vote.acquitter)*100|round} % de condamnation en {$case.vote.condamner+$case.vote.acquitter} votes.		
		</div>
	</div>
	<ul class="nav nav-tabs">
		<li class="active"><a data-toggle="tab" href="#log-chat">Chat</a></li>
		<li><a data-toggle="tab" href="#log-money">Transaction</a></li>
		<li><a data-toggle="tab" href="#log-dead">Mort</a></li>
		<li><a data-toggle="tab" href="#log-jail">Prison</a></li>
		<li><a data-toggle="tab" href="#log-item">Items</a></li>
		<li><a data-toggle="tab" href="#log-vendre">Vente</a></li>
		<li><a data-toggle="tab" href="#log-vol">Vol</a></li>
		<li><a data-toggle="tab" href="#log-connect">Connection</a></li>
		<li><a data-toggle="tab" href="#log-admin">Admin</a></li>
	</ul>
	
</div>
<div class="tab-content" style="max-height: 580px; width:100%; overflow-y:auto; padding:0;">
	<div id="log-chat" class="tab-pane fade in active">
		{loop="$case.list_say"}{$value}{/loop}
	</div>
	<div id="log-money" class="tab-pane fade">
		{loop="$case.list_money"}{$value}{/loop}
	</div>
	<div id="log-dead" class="tab-pane fade">
		{loop="$case.list_dead"}{$value}{/loop}
	</div>
	<div id="log-jail" class="tab-pane fade">
		{loop="$case.list_jail"}{$value}{/loop}
	</div>
	<div id="log-item" class="tab-pane fade">
		{loop="$case.list_item"}{$value}{/loop}
	</div>
	<div id="log-vendre" class="tab-pane fade">
		{loop="$case.list_vendre"}{$value}{/loop}
	</div>
	<div id="log-vol" class="tab-pane fade">
		{loop="$case.list_vol"}{$value}{/loop}
	</div>
	<div id="log-connect" class="tab-pane fade">
		{loop="$case.list_connect"}{$value}{/loop}
	</div>
	<div id="log-admin" class="tab-pane fade">
		{loop="$case.list_admin"}{$value}{/loop}
	</div>
	
</div>
<hr />
<script type="text/javascript">
	$('.showMe').hide();
	$(document).ready(function($) {
		setTimeout( function() {
			$(".btn").attr("disabled",false);
			$(".btn").removeClass("disabled");
			$('[data-toggle="tooltip"]').tooltip('destroy');
			
		}, 16*1000);
		$('[data-toggle="tooltip"]').tooltip({
			placement : 'top'
		});

	});
</script>
