		<script type="text/javascript" src="/js/non-layered-tidy-tree-layout.js"></script>
<style>
* { 
	box-sizing: border-box;
}
#tree {
	position: relative;
}
#legend {
	list-style: none;
}
#legend li::before {
	content: "▮";
}
#legend li:nth-child(1)::before {
	color: #f33;
}
#legend li:nth-child(2)::before {
        color: #ff3;
}
#legend li:nth-child(3)::before {
        color: #3f3;
}
#legend li:last-child::before {
        color: #fff;
}
#tree div>span {
	position: absolute;
	top: 33px;
	left: 2px;
	color: white;
	text-shadow:
	   -1px -1px 0 #000,  
	    1px -1px 0 #000,
	    -1px 1px 0 #000,
	     1px 1px 0 #000;
}

</style>
<div ng-controller="rpCraft">
  <div class="form-group">
    <label class="col-md-4 control-label">Selectionner un craft</label>
    <div class="col-md-7 col-md-offset-1">
      <select ng-model="me" class="form-control">
        <option ng-repeat="i in craft" value="{{i.id}}">{{i.nom}}</option>
      </select>
                </div>
  </div>
  <ul id="legend">
    <li>Forgeron</li>
    <li>Ingénieur</li>
    <li>Alchimiste</li>

    <li>Matière première</li>
  </ul>
	<div ng-show="me!=0" id="tree"></div>
</div>
