<h2> Convertir un SteamID : </h2>

<div class="col-md-12">
	<div class="row clearfix">
		<div class="col-sm-6">
			<h3>Convertir une page Steam en SteamID:</h3>
			<form method="GET" class="form-inline">
				<input type="hidden" name="page" value="steam" />				
				<div class="input-group">
					<input type="text" name="link" id="FriendID2SteamID" onClick="SelectAll('FriendID2SteamID');" size="50" placeholder="http://steamcommunity.com/profiles/aaaaaaaaaa/" class="form-control" />
					<span class="input-group-btn">
						<input type="submit" value="Convertir" class="btn btn-default" />
					</span>
				</div>
			</form>
		</div>
		<div class="col-sm-6">
			<h3>Convertir un SteamID en page Steam:</h3>
			<form method="GET" class="form-inline">
				<input type="hidden" name="page" value="steam" />
				<div class="input-group">
					<input type="text" name="steamid" id="SteamID2FriendID" onClick="SelectAll('SteamID2FriendID');" size="50" placeholder="STEAM_X:Y:ZZZZZ" class="form-control " />
					<span class="input-group-btn">
						<input type="submit" value="Convertir" class="btn btn-default" />
					</span>
				</div>
			</form>
		</div>
		<br /><br /><br /><br />
		<br /><br /><br /><br />
		
	</div>
</div>
