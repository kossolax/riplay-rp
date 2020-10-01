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
	<div class="col-xs-12 col-sm-9">
		<h2 style="font-size:400%" class="text-center"> Help Dev</h2>
		<br /><br />
		<p>Cette page est faite pour vous aider dans la création / maintenance du wiki. Pour tout question, mp forum 
		<a target="_blank" href="https://www.ts-x.eu/forum/memberlist.php?mode=viewprofile&u=13262">Messorem</a> ou faites 
		<a target="_blank" href="https://www.ts-x.eu/forum/viewtopic.php?f=10&t=33820&view=unread#unread">un petit poste ici</a>.</p>
		<br /><br />
		<h2>Les Tableaux</h2>
		<br />
		<p>Par defaut : wiki-table </p><br />
		<table class="wiki-table">
		  <tr>
			<th id="table-top-left">Company</th>
			<th>Contact</th>
			<th id="table-top-right">Country</th>
		  </tr>
		  <tr>
			<td>Alfreds Futterkiste</td>
			<td>Maria Anders</td>
			<td>Germany</td>
		  </tr>
		  <tr>
			<td>Berglunds snabbköp</td>
			<td>Christina Berglund</td>
			<td>Sweden</td>
		  </tr>
		  <tr>
			<td>Centro comercial Moctezuma</td>
			<td>Francisco Chang</td>
			<td>Mexico</td>
		  </tr>
		</table>
		<br />
		<p>Deviante : wiki-table-prune </p><br />
		<table class="wiki-table-prune">
		  <tr>
			<th id="table-top-left">Company</th>
			<th>Contact</th>
			<th id="table-top-right">Country</th>
		  </tr>
		  <tr>
			<td>Alfreds Futterkiste</td>
			<td>Maria Anders</td>
			<td>Germany</td>
		  </tr>
		  <tr>
			<td>Berglunds snabbköp</td>
			<td>Christina Berglund</td>
			<td>Sweden</td>
		  </tr>
		  <tr>
			<td>Centro comercial Moctezuma</td>
			<td>Francisco Chang</td>
			<td>Mexico</td>
		  </tr>
		</table>
		<br />
		<p>Deviante : wiki-table-pomme </p><br />
		<table class="wiki-table-pomme">
		  <tr>
			<th id="table-top-left">Company</th>
			<th>Contact</th>
			<th id="table-top-right">Country</th>
		  </tr>
		  <tr>
			<td>Alfreds Futterkiste</td>
			<td>Maria Anders</td>
			<td>Germany</td>
		  </tr>
		  <tr>
			<td>Berglunds snabbköp</td>
			<td>Christina Berglund</td>
			<td>Sweden</td>
		  </tr>
		  <tr>
			<td>Centro comercial Moctezuma</td>
			<td>Francisco Chang</td>
			<td>Mexico</td>
		  </tr>
		</table>
		<br /> 
		<p>Attention pour arrondir les angles, pensez a mettre en ID "table-top-left" première case, premiere ligne du tableaux et "table-top-right" dernière case, premiere ligne du tableaux.</p>

		<h2>Les classes couleurs</h2>
		<ul>
			<li><span class="blood">blood</span></li> 
			<li><span class="gold">gold</span></li> 
			<li><span class="info">info</span></li> 
			<li><span class="prune">prune</span></li> 
			<li><span class="ocean">ocean</span></li> 
			<li><span class="pomme">pomme</span></li> 
			<li><span class="orange">orange</span></li> 
			<li><span class="txt">txt</span> <span class="info"><= couleur noir</span></li> 
		</ul>

		<h2>Le Panel </h2>
		<p>class="panel panel-wiki" et pour l'en-tête class="panel-heading panel-heading-wiki"</p>
		<br />
		<div class="panel panel-wiki">
			<div class="row">
				<div class="hidden-xs hidden-sm col-md-1">
					<span class="panel-heading panel-icone-wiki"><img src="/images/wiki/logo_wiki.png" /></span> 
				</div>
				<div class="col-md-11">
					<div class="panel-heading panel-heading-wiki"><h1 id="t2" >Titre</h1></div>
				</div>
			</div>
			<div class="panel-body panel-wiki">
			Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,


			</div>
		</div>

		<h2 id="t4">Le Wiki Badge</h2>
		<p>class="wiki-badge"  pour les couleurs : wiki-blue / wiki-red / wiki-green / wiki-orange / wiki-jaune / wiki-prune</p>
		<div class="wiki-badge">defaut</div> <div class="wiki-badge wiki-blue">bleu</div> <div class="wiki-badge wiki-red">rouge</div> <div class="wiki-badge wiki-green">vert</div> <div class="wiki-badge wiki-orange">orange</div> <div class="wiki-badge wiki-jaune">jaune</div> <div class="wiki-badge wiki-prune">prune</div>

		<h2 id="t5">Le Wiki Bulle</h2>
		<p>class="wiki-bulle"  pour les couleurs : wiki-blue / wiki-red / wiki-green / wiki-orange / wiki-jaune / wiki-prune / wiki-bonbon / wiki-cannelle / wiki-ciel / wiki-lemon / wiki-jango</p>
		<div class="wiki-bulle">0</div> <div class="wiki-bulle wiki-blue">1</div> <div class="wiki-bulle wiki-red">2</div> <div class="wiki-bulle wiki-green">3</div> <div class="wiki-bulle wiki-orange">4</div> <div class="wiki-bulle wiki-jaune">5</div> <div class="wiki-bulle wiki-prune">6</div> <div class="wiki-bulle wiki-bonbon">7</div> <div class="wiki-bulle wiki-cannelle">8</div> <div class="wiki-bulle wiki-ciel">9</div> <div class="wiki-bulle wiki-lemon">A</div> <div class="wiki-bulle wiki-jango">B</div>
	</div>
</div>