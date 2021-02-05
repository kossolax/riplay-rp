<div class="block-800" style="text-align:center;">
<h2 class="ThemeLettre clearfix"><div class="left ThemeLettre">Historique: {info} {steamid}</h2>
	<div id="placeholder" style="width:800px; height:{size}px;"></div>
</div>

<script type="text/javascript">
jQuery(function () {
	{graph_data}
	{graph_data_2}
	{graph_data_3}
	

	var plot = jQuery.plot(jQuery("#placeholder"),
		[
			{graph_1}
			{graph_2}
			{graph_3}
		],
		{
			legend: {
				show: true
			},
			series:
			{
				lines: { show: true},
				curvedLines: { active: true }
			},
			grid: {
				hoverable: true,
				clickable: true,
				aboveData: true
			},
			xaxis: {
				mode: "time",
			},
			yaxes: [
				{
					tickFormatter: function (v) { return v + " $"; },
					tickDecimals: 0,
				},
				{
					position: "right",
					tickFormatter: function (v) { return v + " h"; },
					tickDecimals: 2,
					min: 0,
				}
			]
		}
	);

    function showTooltip(x, y, contents) {
        jQuery('<div id="tooltip">' + contents + '</div>').css( {
            position: 'absolute',
            display: 'none',
            top: y + 5,
            left: x + 5,
            border: '1px solid #fdd',
            padding: '2px',
            opacity: 0.80
        }).appendTo("body").fadeIn(200);
    }

    var previousPoint = null;
    jQuery("#placeholder").bind("plothover", function (event, pos, item) {
		jQuery("#x").text(pos.x.toFixed(2));
		jQuery("#y").text(pos.y.toFixed(2));
		if (item) {
			if (previousPoint != item.dataIndex) {
				previousPoint = item.dataIndex;
				jQuery("#tooltip").remove();
				
				var y = item.datapoint[1].toFixed(1);
				showTooltip(item.pageX, item.pageY, ""+y+" " + item.series.label);
			}
		}
		else {
			jQuery("#tooltip").remove();
			previousPoint = null;            
		}
	});
});
</script>
