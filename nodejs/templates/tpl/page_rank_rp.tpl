<div class="row">
	<h2>Le classement {$title}</h2>
	<div class="col-sm-12">
		<table class="table">
			<thead>
				<tr>
					<th>Pos.</th>
					<th>Joueur:</th>
					<th class="hidden-phone"></th>
					<th>Grade:</th>
					<th>Points:</th>
				</tr>
				<tr>
					<th>{$ownData.rank} {$ownData.diff}</th>
					<th  class="hidden-phone">{$ownData.steamid}</th>
					<th>{$ownData.nick}</th>
					<th>{$ownData.rankstr}</th>
					<th>{$ownData.point|pretty_number}
						<span class="label label-{if="$ownData.point-$ownData.old_point>0"}success{elseif="$ownData.point-$ownData.old_point<0"}danger{else} hide{/if}">
							{if="$ownData.point-$ownData.old_point>0"}+{/if}{$ownData.point-$ownData.old_point}
						</span>
					</th>
				</tr>
				<tr>
					<th colspan="5"></th>
				</tr>
			</thead>
			<tbody>
				{loop="$rowData"}
					<tr>
						<td>{$value.rank} {$value.diff}</td>
						<td  class="hidden-phone">{$value.steamid}</td>
						<td>{$value.nick}</td>
						<td>{$value.rankstr}</td>
						<td>{$value.point|pretty_number}
							<span class="label label-{if="$value.point-$value.old_point>0"}success{elseif="$value.point-$value.old_point<0"}danger{else} hide{/if}">
								{if="$value.point-$value.old_point>0"}+{/if}{$value.point-$value.old_point}
							</span>
						</td>
					</tr>
				{/loop}
			</tbody>
		</table>
	</div>
</div>
<br />
