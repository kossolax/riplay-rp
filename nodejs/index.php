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
    <title>Riplay</title>
    <meta charset="utf-8">
    <link rel="icon" type="image/png" href="/images/logo.png" />
    <meta name="description" content="site web de la team .:|ts-x|:.">
    <meta name="keywords" content="ts-x.eu roleplay csgo css kossolax bajail rp-csgo rp-css rp">
    <meta name="author" content="kossolax">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <meta property="og:image" content="/images/ts.png" />

    <link rel="stylesheet" type="text/css" href="/css/bootstrap.css" media="screen">
    <link rel="stylesheet" type="text/css" href="/css/font-awesome.min.css" media="screen, projection" />
    <link rel="stylesheet" type="text/css" href="/css/styles.css">
    
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
        <div class="col-md-12">
            <button class="btn btn-info pull-right" ng-click="goBack()" ng-show="back.length>0">Retour</button>
            <div class="btn-group btn-group-justified" role="group">
            		<a ng-show="isConnectedToForum" class="btn btn-default"  href="#/user/{{steamid}}"><i class="fa fa-user"></i> Bienvenue {{user.name}}</a>
            		<a ng-show="!isConnectedToForum" class="btn btn-default"  href="https://forum.riplay.fr/index.php?/login/"><i class="fa fa-user"></i> Me connecter</a>
            	
                <div class="btn-group" role="group">
                    <button type="button" class="btn btn-default dropdown-toggle" id="dropdownJobList"
                        data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <i class="fa fa-briefcase"></i> Les jobs
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu" aria-labelledby="dropdownJobList">
                        <li ng-repeat="item in jobs">
                            <a href="#/job/{{item.id}}?TABS=player">
                                <span class="pull-left" ng-class="item.steamid ? '' : 'text-danger'"><i
                                        ng-hide="{{item.approuved}}" class="fa fa-exclamation text-danger"
                                        aria-hidden="true"></i>{{item.name}}</span>
                                <i class="pull-right"
                                    ng-class="(item.current-item.quota)>0 ? 'text-success' : (item.current-item.quota)>-2 ? 'text-warning' : 'text-danger'">{{item.current}}
                                    / {{item.quota}}</i>
                                <i class="clearfix"></i>
                            </a>
                        </li>
                    </ul>
                </div>
                <div class="btn-group" role="group">
                    <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown"
                        aria-haspopup="true" aria-expanded="false">
                        <i class="fa fa-users"></i> Les groupes
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu">
                        <li ng-repeat="item in groups" style="background-color:rgba({{item.color}}, 0.1);">
                            <a href="#/group/{{item.id}}">
                                <span class="pull-left">{{item.name}}</span>
                                <i class="pull-right">&nbsp;{{item.stats}}</i>
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
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span
                            aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title">Vous n'êtes pas connecté !</h4>
                </div>
                <div class="modal-body">
                    <b>Vous devez être connecté <font color="red">sur notre forum</font> afin d'accéder pleinement à ce
                        site</b>
                    <br><br>
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
