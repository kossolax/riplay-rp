<div class="row" ng-controller="ctrlIRC">
	<h2 class="clearfix">IRC <a class="btn btn-success" href="#" ng-repeat="item in list" ng-click="$parent.selected = item.username">Stream {{item.name}} de {{item.username}} est disponible !</a></h2>
	<center>
		<iframe src="https://www.ts-x.eu/irc/?nick={$nick}{if="isset($pass)"}&pass={$pass}{/if}&channel=ts-x&autoconnect=1" name="irc_chat" scrolling="no" frameborder="yes" align="center"
			  height="500px" width="99%">
		</iframe>

	</center>

	<a href="#" onclick="enableWebcam(); $(this).hide(); return false;" class="btn btn-info">Activez votre webcam, et voyez qui est sur le chat vidéo !</a>

</div>

<div class="row" id="webcamMenu" style="display:none;">
	<div class="videoContainer"><video height="300" id="localVideo"></video><span>Votre webcam</span></div>
	<div id="remotesVideos"><br /></div>
</div>

<script src="//simplewebrtc.com/latest.js"></script>
<script type="text/javascript">
	var done = 0;	function enableWebcam() {	if( done == 1 ) return; done = 1; var nick = "{$nick}"; $("#webcamMenu").show(); tsxWebcam("{$nick}"); }
</script>
