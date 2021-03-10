<?php 
require_once '/home/www/forum/init.php';
include 'include/function.php';

\IPS\Session\Front::i();

$member = !empty($_SESSION["steamid"]) ? loginViaSteamID($_SESSION["steamid"]) : \IPS\Member::loggedIn();
if( !empty($member->steamid) )
	$_SESSION["steamid"] = $member->steamid;
?>
<html>

<head>
    <title>Riplay.fr | RolePlay CSGO</title>
    <meta charset="utf-8">
    <link rel="icon" type="image/png" href="https://forum.riplay.fr/uploads/monthly_2020_11/Logo_Riplay_BLEU.png" />
    <meta name="description" content="site web de la team Riplay | Roleplay">
    <meta name="keywords" content="ts-x.eu riplay roleplay csgo css kossolax bajail rp-csgo rp-css rp">
    <meta name="author" content="kossolax-Messorem">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">

    <link rel="stylesheet" type="text/css" href="/css/bootstrap.css?v=<?=filemtime('css/bootstrap.css')?>" media="screen">
    <link rel="stylesheet" type="text/css" href="/css/font-awesome.min.css?v=<?=filemtime('css/font-awesome.min.css')?>" media="screen, projection" />
    <link rel="stylesheet" type="text/css" href="/css/styles.css?v=<?=filemtime('css/styles.css')?>">
    <script src="https://kit.fontawesome.com/64bdb6d4ad.js" crossorigin="anonymous"></script>
    <script text="text/javascript" src="https://momentjs.com/downloads/moment.js"></script>
    <script type="text/javascript" src="/js/jquery.2.1.3.min.js"></script>
    <script type="text/javascript" src="/js/bootstrap.js"></script>
    <script type="text/javascript" src="/js/heatmap.min.js"></script>
    <script type="text/javascript" src="/js/jquery.maphilight.js"></script>
    <script type="text/javascript" src="/js/non-layered-tidy-tree-layout.js"></script>
    <script type="text/javascript" src="/js/highcharts.js"></script>
    <script type="text/javascript" src="/js/highcharts-more.js"></script>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.6/angular.js"></script>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.6/angular-route.js"></script>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/angularjs/1.4.6/angular-resource.js"></script>
    <script type="text/javascript" src="/js/angular.dnd.min.js"></script>
	
    <script type="text/javascript">
        Highcharts.setOptions({
            lang: {
                months: ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'],
                weekdays: ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi']
            }
        });
    </script>
    <script>
        var app = angular.module('tsx', ['ngRoute', 'dndLists']);

        var _steamid = '<?php echo $member->steamid; ?>';
        var _member_id = '<?php echo $member->member_id; ?>';
        var _md5 = '<?php echo getIpbSessionId($member->steamid); ?>';

        app.config(function ($httpProvider) {
            $httpProvider.defaults.headers.post['auth'] = _md5;
            $httpProvider.defaults.headers.common['auth'] = _md5;
        });
    </script>
    <script type="text/javascript" src="/js/apps-compiled.js?v=<?=filemtime('js/apps-compiled.js')?>"></script>
</head>
<body ng-app="tsx" ng-controller="mainCtrl" class="container-fluid" style="padding: 50px">
    <?php include './navbar.php';?>
    <header>
        <div class="row visible-lg">
            <div class="btn-group btn-group-justified" role="group">
				<div class="col-md-4">
            		<a ng-show="isConnectedToForum" class="btn btn-default btn-lg btn-block gras"  href="#/user/{{steamid}}"><i class="fa fa-user" style="color:green;">&ensp;</i> Mon profil</a>
            		<a ng-show="!isConnectedToForum" class="btn btn-default"  href="https://forum.riplay.fr/index.php?/login/"><i class="fa fa-user" style="color:red">&ensp;</i> Me connecter</a>
            	</div>
				<div class="col-md-4">
						<button class="btn btn-default btn-lg btn-block dropdown-toggle gras" id="dropdownJobList"
							data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
							<i class="fa fa-briefcase">
							</i> &ensp;Les jobs
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" aria-labelledby="dropdownJobList">
							<li ng-repeat="item in jobs">
								<a href="#/job/{{item.id}}?TABS=player">
									<span class="pull-left" ng-class="item.steamid"><i
											ng-hide="{{item.approuved}}" class="fa fa-exclamation text-danger"
											aria-hidden="true"></i>{{item.name}}&nbsp;&nbsp;</span>
									<i class="pull-right"
										ng-class="(item.current-item.quota)>0 ? 'text-success' : (item.current-item.quota)>-2 ? 'text-warning' : 'text-danger'">&nbsp;&nbsp;{{item.current}}
										/ {{item.quota}}</i>
									<i class="clearfix"></i>
								</a>
							</li>
						</ul>
				</div>
				<div class="col-md-4">
						<button type="button" class="btn btn-default btn-lg btn-block dropdown-toggle gras" data-toggle="dropdown"
							aria-haspopup="true" aria-expanded="false">
							<i class="fa fa-users"></i> &ensp;Les gangs
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu">
							<li ng-repeat="item in groups" style="background-color:rgba({{item.color}}, 0.75);">
								<a href="#/group/{{item.id}}">
									<span class="pull-left" style="color:black; font:bold;">{{item.name}}</span>
									<i class="pull-right" style="color:black; font:bold;">&nbsp;{{item.stats}}</i>
									<i class="clearfix"></i>
								</a>
							</li>
						</ul>
				</div>
            </div>
        </div>
		<!-- Menu Version téléphone -->
		<div class="row hidden-lg">
            <div class="btn-group btn-group-justified" role="group">
				<div class="col-xs-4">
            		<a ng-show="isConnectedToForum" class="btn btn-default btn-lg btn-block gras"  href="#/user/{{steamid}}"><i class="fa fa-user" style="color:green"></i>&ensp;Profil</a>
            		<a ng-show="!isConnectedToForum" class="btn btn-default gras"  href="https://forum.riplay.fr/index.php?/login/"><i class="fa fa-user" style="color:red"></i>&ensp;Connection</a>
            	</div>
				<div class="col-xs-4">
						<button class="btn btn-default btn-lg btn-block dropdown-toggle gras" id="dropdownJobList"
							data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
							<i class="fa fa-briefcase"></i>&nbsp;Jobs
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" aria-labelledby="dropdownJobList">
							<li ng-repeat="item in jobs">
								<a href="#/job/{{item.id}}?TABS=player">
									<span class="pull-left" ng-class="item.steamid"><i
											ng-hide="{{item.approuved}}" class="fa fa-exclamation text-danger"
											aria-hidden="true"></i>{{item.name}}&nbsp;&nbsp;</span>
									<i class="pull-right gras"
										ng-class="(item.current-item.quota)>0 ? 'text-success' : (item.current-item.quota)>-2 ? 'text-warning' : 'text-danger'">&nbsp;&nbsp;{{item.current}}
										/ {{item.quota}}</i>
									<i class="clearfix"></i>
								</a>
							</li>
						</ul>
				</div>
				<div class="col-xs-4">
						<button type="button" class="btn btn-default btn-lg btn-block dropdown-toggle gras" data-toggle="dropdown"
							aria-haspopup="true" aria-expanded="false">
							<i class="fa fa-users"></i>&nbsp;Gangs
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu">
							<li ng-repeat="item in groups" style="background-color:rgba({{item.color}}, 1);">
								<a href="#/group/{{item.id}}">
									<span class="pull-left gras">{{item.name}}</span>
									<i class="pull-right gras">&nbsp;{{item.stats}}</i>
									<i class="clearfix"></i>
								</a>
							</li>
						</ul>
				</div>
            </div>
        </div>
    </header>
    <ng-view></ng-view>

    <div class="modal fade" id="modaleconnect" tabindex="-1" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header text-center">
                    <h4 class="modal-title">Vous n'êtes pas connecté !</h4>
					<!--<button type="button" class="close" data-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">&times;</span></button>-->
                </div>
                <div class="modal-body text-center">
                    <b>Vous devez être connecté <font color="red"><u>sur notre forum</u></font> afin d'accéder pleinement à ce
                        site</b>
                </div>
				<div class="modal-footer text-center">
					<a type="button" href="http://forum.riplay.fr" target="_blank" class="btn btn-success btn-lg">Me connecter</a>
					<a type="button" class="btn btn-secondary btn-lg" style="background-color:#ffc107;color: #fff;" data-dismiss="modal">Fermer</a>
				</div>
            </div>
        </div>
    </div>
</body>
<script>
    if (_member_id == null || _member_id == '' || _md5 == null || _md5 == '') {
        $('#modaleconnect').modal("show");
    }
</script>

</html>
