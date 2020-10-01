		<div class="row">
			<div class="col-sm-3 hidden-phone">
				<div class="container">
					<div class="col-sm-3 hidden-phone">
						<div class="panel-group" id="accordion">
						<div ng-include="'/templates/tpl/aide/menu.tpl'"></div>			
						</div>
					</div>
				</div>
			</div>
			<div class="col-xs-12 col-sm-9">
				<!-- prevoir une images pour remplacer le carrousel en version telephone ? -->
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
                            <img class="img_wiki" src="/images/wiki/debuter.png" alt="320x150">
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
                            <img src="/images/wiki/emploi.png" alt="">
                            <div class="caption">
                                <h4>Trouver un emploi</h4>
								<p class="hidden-sm hidden-md hidden-lg">Envie de changement ?</p>
                               <p class="hidden-phone">{$job} ne te convient pas ? <br />
							   Ici tu découvriras les multiples métiers qui composent notre ville !</p>
                            </div>
							<center><a class="btn btn-warning" href="/index.php?page=aide&sub=emploi"> Aller voir</a></center>
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
                            <img src="/images/wiki/argent.png" alt="">
                            <div class="caption">
                                <h4>Gagner de l'argent</h4>
								<p class="hidden-sm hidden-md hidden-lg">Devenir riche ? facile !</p>
                                <p class="hidden-phone">Tu as {$money|pretty_number} $rp,<br />
							   Ça te suffit pas ? viens voir comment en gagner plus !</p>
                            </div>
							<center><a class="btn btn-success" href="/index.php?page=aide&sub=argent"> $$$ </a></center>
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
				</div>
				<div class="row">
					<div class="col-xs-6 col-sm-6 col-md-4"> 
                        <div class="thumbnail thumbnail-wiki">
                            <img class="img_wiki" src="/images/wiki/mariage.png" alt="">
                            <div class="caption">
                                <h4>Le Mariage</h4>
                               <p> <span class="hidden-phone">Amoureux ?<br /></span>
								Déclare ta flame à ton âme soeur et partagez tout durant 7 jours !</p>
                            </div>
							<center><a class="btn btn-danger" href="https://www.ts-x.eu/index.php?page=aide&sub=debuter#GroupD"> Les avantages </a></center>
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
                            <img src="/images/wiki/nopyj.png" alt="">
                            <div class="caption">
                                <h4>Le rang No-pyj</h4>
                               <p><span class="hidden-phone">Tu as plus de 16 ans ?<br /></span>
							   Viens découvrir les modalités et avantages du rang No-Pyj.</p>
                            </div>
							<center><a class="btn btn-grp" href="/index.php?page=aide&sub=nopyj"> Se renseigner</a></center>
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
                            <img src="/images/wiki/whotsx.png" alt="">
                            <div class="caption">
                                <h4>Qui sont les Ts-X ?</h4>
                                <p><span class="hidden-phone">The Spécialists'X<br /></span>
							   Beaucoup plus qu'un simple nom, ils sont une grande famille...</p>
                            </div>
							<center><a class="btn btn-forum" href="/index.php?page=aide&sub=admin"> Lire </a></center>
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
