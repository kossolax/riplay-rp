<div class="modal fade" id="{errID}">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
			<button type="button" class="close">&#215;</button>
			<h3 class="text-info modal-title" id="myModalLabel">
				{titre}
			</h3>
			</div>
			<div class="modal-body">
				{text}
			</div>
			<div class="modal-footer">
				 <button type="button" class="btn btn-default" data-dismiss="modal">Fermer</button>
			</div>
		</div>
	</div>
</div>
<script type="text/javascript">
$(window).load(function(){
	$('#{errID}').modal('show');
});
</script>
