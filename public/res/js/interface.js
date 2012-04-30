$(document).ready(function() {
		$('.actions_trigger[rel]').overlay({
				top: "center",
				onBeforeLoad: function() {
					var id = this.getTrigger().attr('id');
					var callfun = "/game/service/actions/"+id;
					var menu = this.getOverlay();
					$.ajax({ url: callfun,
			 				 async: true,
		     				 complete: function(XMLHttpRequest, textStatus)
			 				 {
				 				var output=XMLHttpRequest.responseText;
				 				menu.html(output);
							 }
							});
					 }	
			});
		});
