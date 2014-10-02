$(document).ready(function() {
    $('input[type=text]').focus();
    $(document).on('click', '#hit_me input', function () {
	$.ajax({
	    type: 'POST',
	    url: '/hit'
	}).done(function(msg) {
	    $('#game').replaceWith(msg);
	});
	return false;
    });
    $(document).on('click', '#stay input', function () {
	$.ajax({
	    type: 'POST',
	    url: '/stay'
	}).done(function(msg) {
	    $('#game').replaceWith(msg);
	});
	return false;
    });
});
