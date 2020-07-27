<h2>La vue satellite</h2>
<!--
  X <input type="text" ng-model="multiX" value="0"/> <input type="text" ng-model="deltaX" /> <br />
  Y <input type="text" ng-model="multiY" /> <input type="text" ng-model="deltaY" />
-->
<div class="text-right">
  <button class="btn btn-info" ng-click="heatmapStop();" ng-class="timer?'':'disabled'">Vue cartographique</button>
  <button class="btn btn-info" ng-click="!timer && heatmap();" ng-class="timer?'disabled':''">Vue thermique</button>
</div>
<div style="position:relative;">
  <div id="heatmap" style="position:relative; width:100%; top:0px;">
    <img src="/images/roleplay/radar.jpg" style="position:relative; width:100%;" usemap="#simple" id="map" />
    <map name="simple"></map>
    <canvas id='myCanvas' style="z-index:-2; position:absolute; top:0px;"></canvas>
  </div>
  <div style="position:absolute; height:30px; top:5px; left:auto; right:5px;">
    <div ng-show="timer" class="text-right">Il y'a {{connected}} joueurs vivants.</div>
  </div>
</div>
