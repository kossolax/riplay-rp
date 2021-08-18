<link rel="stylesheet" type="text/css" href="/css/wiki/wiki.css" media="screen"> 
<script type="text/javascript" src="/js/wiki/wiki.js"></script>

<style>
.PCwrapper {
	position: relative;
	background: url(/images/pattern.png) repeat;
	width: 110px;
	height: 110px;
	border: 1px solid #aaa;
	border-radius: 100%;
	margin-left:90px;
	margin-top: 10px;
}
.PCwrapper, .PCwrapper * {
	-moz-box-sizing: border-box;
	-webkit-box-sizing: border-box;
	box-sizing: border-box;
}
.PCwrapper .pie {
	width: 50%;
	height: 100%;
	transform-origin: 100% 50%;
	position: absolute;
	background: #aaa;
}
.PCwrapper .spinner {
	border-radius: 100% 0 0 100% / 50% 0 0 50%;
	z-index: 200;
}
.PCwrapper .filler {
	border-radius: 0 100% 100% 0 / 0 50% 50% 0;
	left: 50%;
	opacity: 0;
	z-index: 100;
}
.PCwrapper .mask {
	width: 50%;
	height: 100%;
	position: absolute;
	background: inherit;
	opacity: 1;
	z-index: 300;
	border-radius: 100% 0 0 100% / 50% 0 0 50%;
}
</style>

<div ng-controller="ctrlAide" id="mainWiki">
<div class="hidden-sm hidden-md hidden-lg alert alert-danger" role="alert"><br />
					  <span><img alt="attention" id="img_warning" src="/images/wiki/warning.png"/></span>
					  Vous êtes actuellement sur une Version Beta du mode téléphone.
					</div>
<br /><br />
	
