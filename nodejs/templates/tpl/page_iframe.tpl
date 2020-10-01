<a class="btn btn-info pull-right" href="#" id="linkin">Agrandir la page</a>

<iframe src="blank" style="border:0px #FFFFFF none;" name="myiFrame" id="frame" scrolling="no" frameborder="1" width="100%" style="height:500px;"></iframe>
<script type="text/javascript">
	$(document).ready( function() {
		var x = document.getElementById("frame");
		var y = (x.contentWindow || x.contentDocument);
		var url = window.location.hash.split('#')[1];
		$(x).attr('src', url);
		$("#linkin").attr("href", url);

		setInterval( function() {
			window.location.hash = y.window.location.pathname;
			document.title = y.document.title;
			$(x).css({height: y.document.body.scrollHeight+"px"});
			$("#linkin").attr("href", y.window.location.pathname);
		}, 1000);

	});
</script>
