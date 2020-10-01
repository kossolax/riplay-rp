<br /><br />
</div>
<div class="col-sm-offset-4 col-sm-8 alert alert-warning" role="alert">
	<p class="txt"><span><img alt="attention" id="img_warning" src="/images/wiki/warning.png"/></span>
	Si cette page n'est plus d'actualité, vous pouvez nous le signaler
	<a target="_blank" href="https://www.ts-x.eu/forum/viewtopic.php?f=10&t=33820">ici</a> ou le modifier vous-même sur <a target="_blank" href="https://github.com/ts-x/TSX-WEB/tree/master/templates/tpl/aide">Github</a></p>
</div>
<script type="text/javascript">

	$(document).ready( function() {
		$('body').scrollspy();
	});

  var app = angular.module("tsx")
	.config(function($httpProvider, $locationProvider) {
		$httpProvider.defaults.headers.common['auth'] = _md5;
	})
	.config( ['$provide', function ($provide){
    $provide.decorator('$browser', ['$delegate', function ($delegate) {
    	$delegate.onUrlChange = function () {};
    	$delegate.url = function () { return ""};
    	return $delegate;
    }]);
  }])
	.directive("drawPiePc", function ($compile) {
    return {
      template: '<div class="PCwrapper"><div class="pie spinner" style="transform: rotate({{pc*3.6}}deg)"></div><div class="pie filler" style="opacity: {{pc>=50?1:0}}"></div><div class="mask" style="opacity: {{pc>=50?0:1}}"></div></div>',
      replace: false,
      scope: true,
      link: function(scope, element, attr) {
        scope.pc = attr.drawPiePc;
				if( scope.pc > 100 )
					scope.pc = 100;
				else if( scope.pc < 0.0 )
					scope.pc = 0.0;
      },
    }
  })
	.directive('selectOnClick', ['$window', function ($window) {
	  return {
	    restrict: 'A',
	    link: function (scope, element, attrs) {
	      element.on('click', function () {
	        if( !$window.getSelection().toString() ) {
	          this.setSelectionRange(0, this.value.length);
	        }
					document.execCommand('copy');
	      });
	    }
	  };
	}])
  .controller("ctrlAide", function($scope, $http) {
		$("body").popover({ selector: '[data-toggle="popover"]', trigger: "hover",  html : true});
		$("body").tooltip({ selector: '[data-toggle="tooltip"]', trigger: "hover"});
  })
	.controller("search", function($scope, $http) {
		$scope.data = new Array();

		$scope.$watch("search", function(newValue, oldValue) {
			if( newValue && newValue.length <= 1 ) {
				$scope.data = [];
				return;
			}

			$http.get("https://www.ts-x.eu/api/search/aide/"+newValue).success(function(res) {

				$scope.data = res;

			}).error(function() { $scope.data = []; });
		});
	})
	.controller("vip", function($scope, $http) {
		$http.get("https://www.ts-x.eu/api/panel/props").success(function(res) { $scope.props = res; });
		$scope.focus
		$scope.checkData = function(item, filter) {
			if( filter === undefined )
				return true;

			filter = filter.toLowerCase();

			if( item.model.indexOf(filter) !== -1 )
				return true;
			if( item.nom.indexOf(filter) !== -1 )
				return true;
			if( item.tag.indexOf(filter) !== -1 )
				return true;

			return false;
		}
	})
	.controller("ctrlTabs", function($scope, $http, $attrs) {
		$scope.tabs = "desc";
		$scope.$watch("tabs", function(newValue, oldValue) {

			$scope.users = $scope.items = $scope.jobs = null;
			if( newValue == "memb" )
				$http.get("/api/jobs/"+$attrs.job+"/users").success(function(res) { $scope.users = res; });
			else if( newValue == "item" )
				$http.get("/api/items/job/"+$attrs.job).success(function(res) { $scope.items = res; });
			else if( newValue == "note" || newValue == "hier" )
				$http.get("/api/job/"+$attrs.job).success(function(res) { $scope.jobs = res; });

		});
	});
</script>
