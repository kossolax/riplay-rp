<body>
    <div class="container">
        <div class="row">
			<div class="col-sm-3 hidden-phone">
				<div class="container">
					<div class="col-sm-3 hidden-phone">
						<div ng-controller="search"">
							<input class="form-control" type="text" placeholder="Rechercher" ng-model="search">
							<ul>
								<li ng-repeat="item in data"><a href="index.php?page=aide&sub={{item.ref}}">{{item.ref}}</a></li>
							</ul>
						</div>
						
						<div class="panel-group" id="accordion">
							<div class="panel panel-wiki">
								<div class="panel-heading">
									<h4 class="panel-title">
										<a data-toggle="collapse" data-parent="#accordion" href="#Menupage"><i class="fa fa-chevron-right" aria-hidden="true"></i>
										[menu page]</a>
									</h4>
								</div>
								<div id="Menupage" class="panel-collapse collapse in">
									<ul class="list-group">
										<li class="list-group-item">1</li>
										<li class="list-group-item">2</li>
										<li class="list-group-item">3</li>
										<li class="list-group-item">4</li>
									</ul>
								</div>
							</div>
							<div class="panel panel-wiki">
								<div class="panel-heading">
									<h4 class="panel-title">
										<a href="/index.php?page=aide"><i class="fa fa-chevron-right" aria-hidden="true"></i>
										Accueil</a>
									</h4>
								</div>
							</div>
							<div class="panel panel-wiki">
								<div class="panel-heading">
									<h4 class="panel-title title-nav">
										<a data-toggle="collapse" data-parent="#accordion" href="#MenuOne1"><i class="fa fa-chevron-right" aria-hidden="true"></i>
										Débuter</a>
									</h4>
								</div>
								<div id="MenuOne1" class="panel-collapse collapse">
									<ul class="list-group">
										<li class="list-group-item"><a href="/index.php?page=aide&sub=debuter"><i class="fa fa-book hidden-xs hidden-sm" aria-hidden="true"></i> Comment bien débuter</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=emploi"><i class="fa fa-map-o hidden-xs hidden-sm" aria-hidden="true"></i> Trouver un emploi</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=argent"><i class="fa fa-money hidden-xs hidden-sm" aria-hidden="true"></i> Gagner de l'argent</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=bind"><i class="fa fa-keyboard-o hidden-xs hidden-sm" aria-hidden="true"></i> Comment faire un bind</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=argent#GroupDSub2"><i class="fa fa-bomb hidden-xs hidden-sm" aria-hidden="true"></i> Les events</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=mairie"><i class="fa fa-medium hidden-xs hidden-sm" aria-hidden="true"></i> La Mairie</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=pvp"><i class="fa fa-shield hidden-xs hidden-sm" aria-hidden="true"></i> La PvP</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=debuter#GroupD"><i class="fa fa-heart hidden-xs hidden-sm" aria-hidden="true"></i> Le Mariage [☻CREA☻]</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=crayon"><i class="fa fa-paint-brush hidden-xs hidden-sm" aria-hidden="true"></i> Les crayons de couleur</a></li>
									</ul>
								</div>
							</div>
							<div class="panel panel-wiki">
								<div class="panel-heading panel-menu-header">
									<h4 class="panel-title">
										<a data-toggle="collapse" data-parent="#accordion" href="#MenuTwo"><i class="fa fa-chevron-right" aria-hidden="true"></i>
										Administration</a>
									</h4>
								</div>
								<div id="MenuTwo" class="panel-collapse collapse">
									<ul class="list-group">
										<li class="list-group-item"><a href="/index.php?page=aide&sub=nopyj"><i class="fa fa-graduation-cap hidden-xs hidden-sm" aria-hidden="true"></i> Le rang No-pyj</a></li>
										<li class="list-group-item"><a href="https://www.ts-x.eu/forum/viewtopic.php?f=10&t=26749"><i class="fa fa-university hidden-xs hidden-sm" aria-hidden="true"></i> Règlement général</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=admin#GroupB"><i class="fa fa-user-plus hidden-xs hidden-sm" aria-hidden="true"></i> Les référés</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=emploi#GroupE"><i class="fa fa-user-secret hidden-xs hidden-sm" aria-hidden="true"></i> Devenir chef de Job</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=admin#GroupC"><i class="fa fa-wheelchair hidden-xs hidden-sm" aria-hidden="true"></i> Passer VIP</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=admin#GroupA"><i class="fa fa-coffee hidden-xs hidden-sm" aria-hidden="true"></i> Qui sont les Ts-x</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=admin#GroupD"><i class="fa fa-rebel hidden-xs hidden-sm" aria-hidden="true"></i> Être membre CS:GO</a></li>
									</ul>
								</div>
							</div>
							<div class="panel panel-wiki">
								<div class="panel-heading">
									<h4 class="panel-title">
										<a data-toggle="collapse" data-parent="#accordion" href="#MenuThree"><i class="fa fa-chevron-right" aria-hidden="true"></i>
										Aide</a>
									</h4>
								</div>
								<div id="MenuThree" class="panel-collapse collapse">
									<ul class="list-group">
										<li class="list-group-item"><a href="/index.php?page=aide&sub=debuter#GroupF"><i class="fa fa-headphones hidden-xs hidden-sm" aria-hidden="true"></i> Le teamspeack</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=record"><i class="fa fa-video-camera hidden-xs hidden-sm" aria-hidden="true"></i> Faire une record</a></li>
										<li class="list-group-item"><a href="https://www.ts-x.eu/index.php?page=iframe#/DevZone/"><i class="fa fa-ticket hidden-xs hidden-sm" aria-hidden="true"></i> Les futures maj</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=help"><i class="fa fa-bug hidden-xs hidden-sm" aria-hidden="true"></i> Bugs et problèmes</a></li>
										<li class="list-group-item"><a href="https://www.ts-x.eu/forum/viewtopic.php?f=10&amp;t=28678&amp;view=unread#unread"><i class="fa fa-check hidden-xs hidden-sm" aria-hidden="true"></i> Mise à jour effectué</a></li>
									</ul>
								</div>
							</div>
							<div class="panel panel-wiki">
								<div class="panel-heading">
									<h4 class="panel-title">
										<a data-toggle="collapse" data-parent="#accordion" href="#MenuFour"><i class="fa fa-chevron-right" aria-hidden="true"></i>
										Outils</a>
									</h4>
								</div>
								<div id="MenuFour" class="panel-collapse collapse">
									<ul class="list-group">
										<li class="list-group-item"><a href="/web/messorem/images/"><i class="fa fa-file-image-o hidden-xs hidden-sm" aria-hidden="true"></i> Importer une image</a></li>
										<li class="list-group-item"><a href="https://www.ts-x.eu/forum/viewtopic.php?f=10&t=33820&view=unread#unread"><i class="fa fa-exclamation-triangle hidden-xs hidden-sm" aria-hidden="true"></i> Signaler un problème</a></li>
										<li class="list-group-item"><a href="https://github.com/ts-x/TSX-WEB/tree/master/templates/tpl/aide"><i class="fa fa-cog hidden-xs hidden-sm" aria-hidden="true"></i> Modifier le wiki</a></li>
										<li class="list-group-item"><a href="/index.php?page=aide&sub=vip"><i class="fa fa-database hidden-xs hidden-sm" aria-hidden="true"></i> Beta vip</a></li>
									</ul>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>

            <div class="col-xs-12 col-sm-9">
				<!-- prevoir une images pour remplacer le carrousel en version telephone -->
                <!-- Carrousel -->
				<div id="slider" class="carousel slide" data-ride="carousel">
					<div class="carousel-inner" role="listbox">
						<div class="item active"><!-- Slide 0 -->
							<img id="img_carrousel1" alt="NeW" src="http://rp-csgo.fr/images/rp/1.jpg" />
						</div>
						<div class="item"><!-- Slide 1 -->
							<img id="img_carrousel1" alt="Binds" src="http://rp-csgo.fr/images/rp/2.jpg" />
						</div>
						<div class="item"><!-- Slide 2 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/3.jpg" />
						</div>
						<div class="item"><!-- Slide 3 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/4.jpg" />
						</div>
						<div class="item"><!-- Slide 4 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/5.jpg" />
						</div>
						<div class="item"><!-- Slide 5 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/6.jpg" />
						</div>
						<div class="item"><!-- Slide 6 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/7.jpg" />
						</div>
						<div class="item"><!-- Slide 7 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/8.jpg" />
						</div>
						<div class="item"><!-- Slide 8 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/9.jpg" />
						</div>
						<div class="item"><!-- Slide 9 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/10.jpg" />
						</div>
						<div class="item"><!-- Slide 10 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/11.jpg" />
						</div>
						<div class="item"><!-- Slide 11 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/12.jpg" />
						</div>
						<div class="item"><!-- Slide 12 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/13.jpg" />
						</div>
						<div class="item"><!-- Slide 13 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/14.jpg" />
						</div>
						<div class="item"><!-- Slide 14 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/15.jpg" />
						</div>
						<div class="item"><!-- Slide 15 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/16.jpg" />
						</div>
						<div class="item"><!-- Slide 16 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/17.jpg" />
						</div>
						<div class="item"><!-- Slide 17 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/18.jpg" />
						</div>
						<div class="item"><!-- Slide 18 -->
							<img id="img_carrousel1" alt="PVP" src="http://rp-csgo.fr/images/rp/19.jpg" />
						</div>
						
					</div>
					<!-- Controle gauche -->
					<a class="left carousel-control" href="#slider" role="button" data-slide="prev">
					<span class="sr-only">Previous</span></a>
					<!-- Controle droite -->
					<a class="right carousel-control" href="#slider" role="button" data-slide="next">
					<span class="sr-only">Next</span></a>
				</div>
				<br />
                <div class="row">
                    <div class="col-xs-6 col-sm-6 col-md-4"> 
                        <div class="thumbnail thumbnail-wiki">
                            <img class="img_wiki" src="http://i.picresize.com/images/2016/12/27/MWbdN.png" alt="320x150">
                            <div class="caption">
                                <h4>Bien débuter</h4>
                               <p> Bienvenue {$name} !<br />
								<span class="hidden-phone">Si tu souhaites en savoir plus sur les rouages de Princeton, c'est ici !</span></p>
                            </div>
							<center><a class="btn btn-mp" href="/index.php?page=aide&sub=debuter"> En savoir plus </a></center>
							<br />
                            <div class="ratings">
								<p>Importance :
                                    <span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
                                </p>
                            </div>
                        </div>
                    </div>
					<div class="col-xs-6 col-sm-6 col-md-4">
                        <div class="thumbnail thumbnail-wiki">
                            <img src="http://i.picresize.com/images/2016/12/27/d4SVA.png" alt="">
                            <div class="caption">
                                <h4>Trouver un emploi</h4>
								<p class="hidden-sm hidden-md hidden-lg">Envie de changement ?</p>
                               <p class="hidden-phone">{$job} ne te conviens pas ? <br />
							   Ici tu découvriras les multiples métier qui composent notre ville !</p>
                            </div>
							<center><a class="btn btn-warning" href="/index.php?page=aide&sub=debuter"> Aller voir</a></center>
							<br />
                            <div class="ratings">
								<p>Importance :
                                    <span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star-half-o" aria-hidden="true"></i></span>
                                </p>
                            </div>
                        </div>
                    </div>
					<div class="col-xs-6 col-sm-6 col-md-4">
                        <div class="thumbnail thumbnail-wiki">
                            <img src="http://i.picresize.com/images/2016/12/27/4zdZ.png" alt="">
                            <div class="caption">
                                <h4>Gagner de l'argent</h4>
								<p class="hidden-sm hidden-md hidden-lg">Devenir riche ? facile !</p>
                                <p class="hidden-phone">Tu as {$money|pretty_number} $rp,<br />
							   Ça te suffis pas ? viens voir comment en gagner plus !</p>
                            </div>
							<center><a class="btn btn-success" href="/index.php?page=aide&sub=debuter"> $$$ </a></center>
							<br />
                            <div class="ratings">
								<p>Importance :
                                    <span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star-o" aria-hidden="true"></i></span>
                                </p>
                            </div>
                        </div>
                    </div>
					<div class="col-xs-6 col-sm-6 col-md-4"> 
                        <div class="thumbnail thumbnail-wiki">
                            <img class="img_wiki" src="http://i.picresize.com/images/2016/12/28/ViUrf.png" alt="">
                            <div class="caption">
                                <h4>Le Mariage</h4>
                               <p> <span class="hidden-phone">Amoureux ?<br /></span>
								Déclare ta flame à ton âme soeur et partagez tous durant 7 jours !</p>
                            </div>
							<center><a class="btn btn-danger" href="/index.php?page=aide&sub=debuter"> Les avantages </a></center>
							<br />
                            <div class="ratings">
								<p>Importance :
                                    <span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star-half-o" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star-o" aria-hidden="true"></i></span>
                                </p>
                            </div>
                        </div>
                    </div>
					<div class="col-xs-6 col-sm-6 col-md-4">
                        <div class="thumbnail thumbnail-wiki">
                            <img src="http://www.nt2e.com/assets/img/solution-thumbnail.gif" alt="">
                            <div class="caption">
                                <h4>Le rang No-pyj</h4>
                               <p><span class="hidden-phone">Tu as plus de 16 ans ?<br /></span>
							   Viens découvrir les modalitées et avantages du rang No-Pyj.</p>
                            </div>
							<center><a class="btn btn-grp" href="/index.php?page=aide&sub=debuter"> Ce renseigner</a></center>
							<br />
                            <div class="ratings">
								<p>Importance :
                                    <span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star-o" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star-o" aria-hidden="true"></i></span>
                                </p>
                            </div>
                        </div>
                    </div>
					<div class="col-xs-6 col-sm-6 col-md-4"> 
                        <div class="thumbnail thumbnail-wiki">
                            <img src="http://i.picresize.com/images/2016/12/28/osWd7.png" alt="">
                            <div class="caption">
                                <h4>Qui sont les Ts-X ?</h4>
                                <p><span class="hidden-phone">The Spécialists'X<br /></span>
							   Beaucoup plus qu'un simple nom, ils sont une grande famille...</p>
                            </div>
							<center><a class="btn btn-forum" href="/index.php?page=aide&sub=debuter"> Lire </a></center>
							<br />
                            <div class="ratings">
								<p>Importance :
                                    <span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star-half-o" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star-o" aria-hidden="true"></i></span>
									<span style="color: yellow;"><i class="fa fa-star-o" aria-hidden="true"></i></span>
                                </p>
                            </div>
                        </div>
                    </div>
				</div>
            </div>
        </div>
    </div>
</body>
