function showLog()
{
	$('#inttip').removeClass('active');
	$('#logtip').addClass('active');
	$('#intelligence').hide();
	$('#messages').show();
}
function showIntelligence()
{
	$('#intelligence').html("Clicca su INFO di un elemento per averne la descrizione");
	$('#inttip').addClass('active');
	$('#logtip').removeClass('active');
	$('#intelligence').show();
	$('#messages').hide();
}

$(document).ready(function() {
		$('.actions_trigger').click(function() {
				var id = $(this).parent().attr('id');
				var callfun = "/game/service/actions/"+id;
				$.ajax({ url: callfun,
		 				 async: true,
		   				 complete: function(XMLHttpRequest, textStatus)
		 				 {
			 				var output=XMLHttpRequest.responseText;
			 				$('#interaction').html(output);
						 }
				});
				return false;
			});
		$('.info_trigger').click(function() {
				var id = $(this).parent().attr('id');
				var callfun = "/game/service/description/"+id;
				$.ajax({ url: callfun,
		 				 async: true,
		   				 complete: function(XMLHttpRequest, textStatus)
		 				 {
			 				var output=XMLHttpRequest.responseText;
			 				$('#intelligence').html(output);
							$('#logtip').removeClass('active');
							$('#inttip').addClass('active');
							$('#messages').hide();
							$('#intelligence').show();
						 }
				});
				return false;
			});
});
