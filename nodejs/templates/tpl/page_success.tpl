<div class="block-600">
<h2 class="ThemeLettre">Les succ&egrave;s de: {$name} <div class="pull-right">{$cpt}/{$SuccessData|count}</div></h2>
	{loop="SuccessData"}{if="$value.5>=1"}
	<div style="width:12.5%; float:left;"
		data-toggle="tooltip" data-original-title="<span style='font-weight:bold;'>{$value.1}</span>: {$value.2}" data-html="true">
		<img src="/images/success/{$value.0}.jpg" class="img-polaroid" />
	</div>
	{/if}{/loop}
	{loop="SuccessData"}{if="$value.5<=0"}
        <div style="width:12.5%; float:left;"
                data-toggle="tooltip" data-original-title="<span style='font-weight:bold;'>{$value.1}</span>: {$value.2}" data-html="true">

		<img src="/images/success/disabled/{$value.0}.jpg" class="img-polaroid" style="position:relative;"/>
		<div class="progress" style="margin:0px; padding:0px;margin-top:-10px;height:10px;z-index:2;position:relative;border-radius:2px;">
			<div class="progress-bar" role="progressbar" aria-valuenow="{function="$value.5/$value.3*100"}" aria-valuemin="0" aria-valuemax="100"
				style="width:{function="$value.4/$value.3*100"}%; font-size:8px; line-height:10px;">{$value.4}/{$value.3}</div>
		</div>
        </div>
	{/if}{/loop}
</div>
<br />

<script type="text/javascript">
        $(document).ready(function($) {
                $('[data-toggle="tooltip"]').tooltip({
                        placement : 'top'
                });

        });
</script>

