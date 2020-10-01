	<a href="#" id="toTop"><span id="toTopHover"></span></a>
</div>
<footer>
	<div class="container">
<!--
		<article class="col-sm-2">
			<div class="row">
				<h4>Les journaux</h4>
				<ul class="list2">
					{$listJournal}
				</ul>
			</div>
		</article>
-->
		<article class="col-sm-offset-2 col-sm-8 comments">
			<div class="row">
				<a href="/forum/search.php?search_id=unreadposts"><h4 class="text-center">Pendant ce temps, sur le forum...</h4></a>
				<ul class="list3" style="word-wrap: break-word;">
					{$listForum}
				</ul>
			</div>
		</article>
<!--
		<article class="col-sm-3">
			<div class="row">
				<h4>La Ts-X tv présente :</h4>
				<div class="video">
					<p>Les Braquages</p><br />
					<figure><a class="various" target="_blank" href="https://www.youtube.com/watch?v=RtNNPcaTzO0" style="opacity: 1;"></a><img alt="ts_x" src="/images/tv_tsx_brkg.png" class="img_phone"></figure>
			    </div>
			</div>
		</article>
-->
	</div>
	<br /><br />
	<div class="container">
		<p>Copyright &copy; 2010-2017 &bull; <a href="https://www.ts-x.eu">ts-x.eu</a> &bull; KoSSoLaX`</p>
	</div>

	<style>
		.bulb {
			background-image: url("/images/bulbs-32x32-bottom.png");
			display: inline-block;
			width: 32px;
			height: 32px;
			position: fixed;
			bottom: 0px;
		}
		.bulblette {
			display: inline-block;
			width: 32px;
			height: 32px;
			position: fixed;
			font-size: 20px;
		}

	</style>
<!--
	<div ng-controller="lights" id="lights">
		<div ng-repeat="i in bulb track by $index"
			class="bulb bulb-{{i.color}}"
			style="left:{{i.id*32}}px; background-position: -{{i.state*32}}px {{i.color*32}}px;" ng-mouseover="explode(i.id)"></div>
	</div>
-->
</footer>
	<script type="text/javascript" src="https://www.ts-x.eu/js/compile-bootstrap-globals-login-jquery.event.move.js?v=467"></script>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

	ga('create', 'UA-32533306-1', 'ts-x.eu');
	ga('send', 'pageview');
</script>
</body>
</html>
