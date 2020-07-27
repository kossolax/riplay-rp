
<label>Filtre: <input type="text" class="form-control" ng-model="monFiltre" ng-change="lower = monFiltre.toLowerCase()" placeholder="nom d'un item" value=""></label>
<!--{{HDV.length}}-->
<br clear="all" />
<ul class="col-md-2 list-style-none">
  <li ng-repeat="item in $parent.jobs" ng-if="item.id != 1 && item.id != 101 && item.id != 181">
    <a href="#/hdv/{{item.id}}">
      <span class="pull-left">{{item.name}}</span>
  	</a>
  </li>
</ul>
<ul class="col-md-10">
  <li ng-repeat="item in HDV" ng-if="monFiltre.length < 1 || item.nom.toLowerCase().indexOf(lower) != -1" style="width:50%; float:left;">
    <img src="/images/roleplay/csgo/items/{{item.itemID}}.png" width="60" height="60">
    Nom: <strong>{{item.nom}}</strong>
    Prix unité: <strong>{{item.price}}$</strong>
    Quantité: <strong>{{item.amount}}</strong>
    PRIX HTVA: <strong>{{item.price*item.amount*item.fees}}$</strong>
    PRIX TVA: <strong>{{item.price*item.amount}}$</strong>
  </li>
</ul>
