<div class="row clearfix">
<h2>Les serveurs .:|ts-<span class="ThemeColor">X</span>|:.</h2>
	{loop="row"}
		<div class="row">
			<div class="col-sm-8 col-sm-offset-1">
				<h3>{$value.hostname}</h3>
				<br />
				<div class="row">
					<label class="col-xs-2 control-label col-xs-offset-1">MAP: </label>
					<div class="col-xs-6">
						{$value.map}
					</div>
				</div>
				<div class="row">
					<label class="col-xs-2 control-label col-xs-offset-1">IP: </label>
					<div class="col-xs-6">
						<a href="steam://connect/{$value.ip}:{$value.port}/">{$value.ip}:{$value.port}</a>
					</div>
				</div>
				<div class="row">
					<label class="col-xs-2 control-label col-xs-offset-1">Joueurs: </label>
					<div class="col-xs-6">
						{$value.num_players} / {$value.max_players}
					</div>
				</div>
				
			</div>
			<div class="col-sm-2">
				<img src="http://image.www.gametracker.com/images/maps/160x120/{$value.game}/{$value.url}.jpg" class="img-polaroid" />
			</div>
		</div>
		<hr />
	{/loop}
	</center>
</div>
<br />