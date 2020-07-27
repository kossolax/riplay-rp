<div ng-controller="rpGraph">
  <div class="form-group">
    <label class="col-md-4 control-label">Selectionner un job</label>
    <div class="col-md-7 col-md-offset-1">
      <select ng-model="me" class="form-control">
        <option value="0" selected>Tous les jobs</option>
        <option ng-repeat="i in jobs" ng-if="i.id != 1 && i.id != 91 && i.id != 101 && i.id != 181" value="{{i.id}}">{{i.name}}</option>
      </select>
		</div>
  </div>
  <div id="graph" draw-pie-chart="{{url}}" style="height:700px;"></div>
</div>
