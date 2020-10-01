<div class="block-800" style="margin:auto;">
	<h2 class="ThemeLettre">Graphique des {titre}</h2>
<div id="myGraph" style="width:800px; height:700px;"></div>
</div>
<script type="text/javascript">
function labelFormatter(label, series) {
	return "<div style='font-size:8pt; text-align:center; padding:2px; color:white;'>" + label + "<br/>" + Math.round(series.percent) + "%</div>";
}
$(document).ready(function() {
	$.plot('#myGraph',
		{data},
		{
			series: {
				pie: {
					show: true,
					innerRadius: 0.25,
					radius: 1,
					label: {
						show: true,
						radius: 1,
						formatter: labelFormatter,
						background: {
							opacity: 0.5,
							color: '#000'
						}
					}
				}
			},
			grid: {
				hoverable: true
			},
			legend: { show: false },
		}
	);
});
</script>
