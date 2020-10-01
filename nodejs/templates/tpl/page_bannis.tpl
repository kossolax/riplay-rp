<br />
<div class="col-sm-4 col-sm-offset-8">
<form action="index.php" method="get">
	<div class="form-inline">
		<input type="hidden" name="page" value="bannis" />
		<div class="input-group">
			<input type="text" name="lookat" value="{$lookat}" class="form-control" placeholder="STEAM_0:x:abcdef"/>
			<span class="input-group-btn">
				<input type="submit" class="btn" value="Rechercher" />
			</span>
		</div>
	</div>
</form>
</div>
{if="$admin==1"}
<form action="index.php?page=bannis&action=add" method="post">
        <div class="form-inline">
		<div class="input-group">
			<input type="text" name="steamid" value="" class="form-control" placeholder="STEAM_0:x:abcdef"/>
		</div>
		<div class="input-group">
			<input type="text" name="time" value="" class="form-control" placeholder="1440 temps en minutes"/>
		</div>
		<div class="input-group">
			<input type="text" name="reason" value="" class="form-control" placeholder="Raison..."/>
		</div>
		<div class="input-group">
			<select name="game" class="form-control"><option value="csgo">Counter-Strike: GO</option><option value="rp-kill">Roleplay: KILL</option><option value="rp-pvp">Roleplay: PvP</option><option value="rp-global">Roleplay: Chat Global</option><option value="rp-vocal">Roleplay: Chat Vocal</option><option value="rp-local">Roleplay: Chat Local</option><option value="rp-event">Roleplay: Event</option><option value="tf">Team Fortress</option><option value="forum">FORUM</option><option value="teamspeak">TeamSpeak</option><option value="ALL">Global</option><option value="teamspeak">TeamSpeak</option><option value="tribunal">Tribunal</option></select>
		</div>
		<div class="input-group">
                        <input type="submit" class="btn" value="Bannir" />
                </div>
        </div>
</form>
{/if}
<br />
<table class="col-md-12 table table-condensed table-hover">
<thead>
	<tr>
		{if="$admin==1"}<th style="width:55px;">X</th>{/if}
		<th style="width:50px;">Jeu:</th>
		<th>Joueur:</th>
		<th class="hidden-phone">SteamID:</th>
		<th>Raison:</th>
		<th>Bannis par:</th>
		<th>Jusqu'au</th>
	</tr>
</thead>
<tbody>
	{loop="$row"}
        <tr class="text-{if="$value.is_unban==1"}success{elseif="$value.EndTime>time()"}warning{elseif="$value.Length==0"}danger{else}success{/if}">
                {if="$admin==1"}<td><form action="index.php?page=bannis&action=remove" method="post"><input type="hidden" name="id" value="{$value.id}" /><input type="submit" value="d&eacute;ban" class="btn btn-xs btn-danger"/></form></td>{/if}
                <td><img src='/images/icons/section/{$value.game}.png' width='16' /><span class="label label-{if="$value.score>6"}danger{elseif="$value.score>1"}warning{else}success{/if}">{$value.score}</span></td>
                <td>{$value.nick}</td>
                <td class="hidden-phone"><a href="/index.php?page=bannis&lookat={$value.SteamID}" class="text-{if="$value.is_unban==1"}success{elseif="$value.EndTime>time()"}warning{elseif="$value.Length==0"}danger{else}success{/if}">{$value.SteamID}</a></td>
                <td>{$value.BanReason}</td>
                <td>{$value.admin}</td>
                <td>{if="$value.Length==0"}Permanent{else}{$value.EndTime|nicetime}{/if}</td>
        </tr>
	{/loop}
</tbody>
</table>

<div class="row clearfix">
	<br />
	{if="$max>0"}
	<a href="/index.php?page=bannis&max={$max-1}&lookat={$lookat}" class="btn btn-default">Plus récent</a>
	{/if}
	<a href="/index.php?page=bannis&max={$max+1}&lookat={$lookat}" class="btn btn-default pull-right">Plus vieux</a>
	<br /><br />
</div>
