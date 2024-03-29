"use strict";
exports = module.exports = function(app) {

  app.directive('drawUserChart', function ($http) {
    return function (scope, element, attr) {
      $http.get(attr.drawUserChart).then(function(res) {
        //console.log(res);
        var chart = new Highcharts.Chart({
          chart: { 
            renderTo: $(element).attr("id"), 
            type: 'areaspline', 
            backgroundColor: null, 
            zoomType: 'x'
          },
          credits: { 
            enabled: false 
          }, 
          legend: { 
            align: 'right', 
            verticalAlign: 'top'
          },
          xAxis: { 
            tickInterval: 24*3600*1000, 
            type: 'datetime' 
          },
          title: { 
            text: res.title, 
            style: { 
              color: '#aaa', 
              textDecoration: 'underline'
            }, 
            align: 'left' 
          },
          tooltip: { 
            shared: true, 
            valueSuffix: '$',
          },
          plotOptions: { 
            series: { 
              stacking: 'normal', 
              pointPadding: 0, 
              groupPadding: 0, 
              fillOpacity: 0.25
            } 
          },
          yAxis: res.data.axis, 
          series: res.data.data
        });

        console.log(chart);
      });
    }
  });
  app.directive('drawPieChart', function ($http) {
    return function (scope, element, attr) {
      $http.get(attr.drawPieChart).then(function(res) {
        var chart = new Highcharts.Chart({
          chart: { renderTo: $(element).attr("id"), type: 'pie', backgroundColor: null},
          credits: { enabled: false }, legend: { align: 'right', verticalAlign: 'top'},
          tooltip: { shared: true, pointFormat: 'Pourcent: <b>{point.percentage:.1f}%</b><br />Argent: <b>{point.y}</b>$' },
          title: { text: null },
          plotOptions: { pie: { allowPointSelect: true, showInLegend: true} },
          xAxis: res.data.axis, series: res.data.data
        });
      });
    }
  });
  app.directive('drawRadarChart', function ($http) {
    return function (scope, element, attr) {
      $http.get(attr.drawRadarChart).then(function(res) {
        var chart = new Highcharts.Chart({
          chart: { renderTo: $(element).attr("id"), type: 'area', polar: true, backgroundColor: null, zoomType: 'x'},
          credits: { enabled: false }, legend: { enabled: false },
          title: { text: null },
          xAxis: res.data.axis, series: res.data.data,
          tooltip: { formatter: function() { return '<b>'+ this.x + '</b>: '+ this.y+'%'; } },
          yAxis: { gridLineInterpolation: 'polygon', lineWidth: 0, min: 0, max: 100}
        });
      });
    }
  });

  app.directive('drawLine', function ($window) {
    return function (scope, element, attr) {
      var w = angular.element($window);

      w.bind('resize', function () { update() });
      $("#skin").bind('load', function() { update() });

      var update = function() {
        if( !scope.data || scope.data.skin == 0 )
          return;
        $(element).css({position : 'relative'});

        var off1 = $(element).offset();
        var off2 = $("#skin").offset();
        var off3 = attr.drawLine.split(',');

        var x1, y1;
        if( off3[0] == "right" ) {
          x1 = $(element).outerWidth();
          y1 = $(element).outerHeight() / 2;
        }
        else if( off3[0] == "left" ) {
          x1 = 0;
          y1 = $(element).outerHeight() / 2;
        }

        var x2 = off2.left - off1.left + parseInt(off3[1]);
        var y2 = off2.top - off1.top + parseInt(off3[2]);

        var length = Math.sqrt(((x2-x1) * (x2-x1)) + ((y2-y1) * (y2-y1)));
        var angle = Math.atan2((y1-y2),(x1-x2))*(180/Math.PI);
        var cx = ((x1 + x2) / 2) - (length / 2);
        var cy = ((y1 + y2) / 2) - (2 / 2);

        var htmlLine = "<div class='arrow' style='padding:0px; margin:0px; height:2px; background-color:white; line-height:1px; position:absolute; left:" + cx + "px; top:" + cy + "px; width:" + length + "px; -moz-transform:rotate(" + angle + "deg); -webkit-transform:rotate(" + angle + "deg); -o-transform:rotate(" + angle + "deg); -ms-transform:rotate(" + angle + "deg); transform:rotate(" + angle + "deg);' />"

        $(element).find(".arrow").remove();
        $(element).append(htmlLine);
      }
      return;
    }
  });
  app.directive("modalShow", function ($parse) {
    return {
      restrict: "A",
      link: function (scope, element, attrs) {
        scope.showModal = function (visible, elem) {
          if (!elem)
            elem = element;
          if (visible)
            $(elem).modal("show");
          else
            $(elem).modal("hide");
        }
        scope.$watch(attrs.modalShow, function (newValue, oldValue) {
          scope.showModal(newValue, attrs.$$element);
        });
        $(element).bind("hide.bs.modal", function () {
          $parse(attrs.modalShow).assign(scope, false);
          if (!scope.$$phase && !scope.$root.$$phase)
            scope.$apply();
        });
      }
    };
  });
  app.directive('rest', function ($http, $window, $location, $sce) {
    return function (scope, element, attr) {
      element.bind('click', function () {

        var str = attr.rest;
        var confir = str.charAt(0);
        if( confir == '!' )
          str = str.substring(1);

        var method = str.split("@");
       
        if( confir == '!' ) {
          scope.$parent.showAlert = true;
          scope.$parent.messageAlert = "Êtes vous sur de vouloir \""+element.html()+"\" ?";
          scope.$parent.messageTitle = "Confirmation";
          scope.$parent.messageUrl = method[1];
          scope.$parent.messageAction = method[0];
        }
        else {
          method[1] = "https://riplay.fr/api" + method[1];
          $http({url: method[1], method: method[0].toUpperCase()})
          .then(function(res) { 
            if( res.data.redirect ) { 
              $location.path(res.data.redirect); 
            } 
            if( attr.redirect ) {
              $location.path(attr.redirect);
            }
            scope.$parent.showAlert = true; 
            scope.$parent.messageAlert = res.data.message;
            res.message; scope.$parent.messageTitle = "Okay";  
          },function (res){
            scope.$parent.showAlert = true; 
            scope.$parent.messageAlert = res.data.message; 
            scope.$parent.messageTitle = "Erreur"; 
          });
        }

      });
    }
  });


};
