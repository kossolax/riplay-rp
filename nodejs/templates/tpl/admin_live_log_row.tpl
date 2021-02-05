<br />
<div class="LiveLogBlock">
	<div class="LiveLogTitle">
		<div class="left"><a href="admin.php?page=live_log&serv_ip={ip}&serv_port={port}">{hostname}</a></div>
		<div class="right">
			<span class="no_height no_width no_visible no_overflow LiveID">-1</span>
			<a href="steam://connect/{ip}:{port}">
				<span class="LiveIP">{ip}</span>:<span class="LivePORT">{port}</span><span class="LivePASS" style="display:none;">{pass}</span>
			</a>
		</div>
		<br />
		<div class="center" style="font-size:12px;">
		Aficher: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				Pause <input type="checkbox" class="LiveCheck_Status" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				Connexion <input type="checkbox" class="LiveCheck_Connexion" checked>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				Mort <input type="checkbox" class="LiveCheck_Mort" checked>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				Chat <input type="checkbox" class="LiveCheck_GlobalChat" checked>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				AdminCmd <input type="checkbox" class="LiveCheck_AdminCmd" checked>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				MessageServ <input type="checkbox" class="LiveCheck_ServMsg" checked>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		</div>
	</div>
	<div class="LiveLogItself{is_only_one}"></div>
</div>
