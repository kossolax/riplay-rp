<div class="container bs-docs-container" data-spy="scroll" data-target="#sidebar" ng-controller="vip">		
				<div class="row">
				<div class="col-sm-3 hidden-phone">
					<div class="container">
						<div class="col-sm-3 hidden-phone">
							<div class="panel-group" id="accordion">
								<!--<div class="panel panel-wiki">
									<div class="panel-heading">
										<h4 class="panel-title title-nav">
											<a data-toggle="collapse" data-parent="#accordion" href="#MenuOne"><i class="fa fa-chevron-right" aria-hidden="true"></i>
											Index</a>
										</h4>
									</div>
									<div id="MenuOne" class="panel-collapse collapse">
										<ul class="list-group">
											<li class="list-group-item"><a href="#GroupA">Présentation</a></li>
											<li class="list-group-item"><a href="#GroupB">Les Référés</a></li>
											<li class="list-group-item"><a href="#GroupC">Passer VIP</a></li>
											<li class="list-group-item"><a href="#GroupD">Devenir Membre CS:GO</a></li>
										</ul>
									</div>
								</div>-->
								<div ng-include="'/templates/tpl/aide/menu.tpl'"></div>			
							</div>
						</div>
					</div>
				</div>
				<div class="col-xs-12 col-sm-7">			
					<br /><br />			
					<center>
						<img alt="img_title" id="img_title" src="/images/wiki/admin/admin_top.png">
					</center>
					<br /><br />
					<div class="row">
						<div id="GroupA" class="col-md-12 group">
							<div class="panel panel-wiki">
								<div class="row">
									<div class="hidden-xs hidden-sm col-md-1">
										<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span>
									</div>
									<div class="col-md-11">
										<div class="panel-heading panel-heading-wiki">
											<h2>Tous les props</h2>
										</div>
									</div>
								</div>
								<div class="panel-body">
									<div id="GroupASub1">
										<p style="text-align: center; margin: 0 0 2em 0">Faites Ctrl+C pour copier le model puis allez dans votre console CS:GO et faites Ctrl+V pour le coller</p>
										<div class="row">
											<div class="col-sm-6 col-md-3" ng-repeat="item in props" ng-if="checkData(item, filter)">
												<div class="thumbnail">
													<img src="/web/messorem/images/props/{{item.id}}.jpg" alt="{{item.id}}" style="height:150px; width:300px;" >
												</div>
												<div class="caption">
													<p style="text-align: center;"><span style="font-size: 1.17em;font-weight: bold;" > {{item.nom}}</span><br /> [ {{item.tag}} ]</p>
													<input class="form-control" type="text" value="{{item.model}}" select-on-click />											<p>&nbsp;</p>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>		
				</div>		
				<nav class="col-md-2 bs-docs-sidebar">			
					<ul id="sidebar" class="nav nav-stacked fixed">				
						<input class="pull-right form-control" placeholder="RECHERCHER UN PROPS" type="text" name="search" ng-model="filter" />	
					</ul>		
				</nav>
			</div>