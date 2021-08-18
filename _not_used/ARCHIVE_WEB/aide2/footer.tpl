<br /><br />
</div>
<div class="col-sm-offset-1 col-sm-8 alert alert-warning" role="alert">
	<p class="txt"><span><img alt="attention" id="img_warning" src="/images/wiki/warning.png"/></span>
	Si cette page n'est plus d'actualité, vous pouvez nous le signalez
	<a href="https://www.ts-x.eu/forum/viewtopic.php?f=10&t=33820">ici</a>
	ou le modifier vous même sur <a href="https://github.com/ts-x">Github</a></p>
</div>

<script type="text/javascript">
  var app = angular.module("tsx", [])
  .directive("rpItemInformation", function($compile, $http) {
		return {
			template: '<img class="img-circle" width="100" height="100" src="/images/roleplay/csgo/items/{{item.id}}.png" data-toggle="popover" data-placement="top" title="{{item.nom}}" data-content="{{item.prix}}$ vendu par {{item.job}}">',
			replace: false,
			scope: true,
			link: function(scope, element, attr) {
				$http.get("https://www.ts-x.eu/api/items/"+attr.rpItemInformation).success(function(res) {
					scope.item = res;
	      });
			}
		}
  })
  .controller("ctrlAide", function($scope, $http) {
		$("body").popover({ selector: '[data-toggle="popover"]', trigger: "hover"});
		$("body").tooltip({ selector: '[data-toggle="tooltip"]', trigger: "hover"});
  });

</script>
