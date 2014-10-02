$(document).ready(function() {
    $('input[type=text]').focus();
    ajaxify('#hit_me input', '/hit');
    ajaxify('#stay input', '/stay');
    ajaxify('#dealer_hit input', '/dealer_hit');
});

function ajaxify (csstar, whereto) {
    $(document).on('click', csstar, function () {
	$.ajax({
	    type: 'POST',
	    url: whereto
	}).done(function(msg) {
	    $('#game').replaceWith(msg);
	});
	return false;
    });
};
