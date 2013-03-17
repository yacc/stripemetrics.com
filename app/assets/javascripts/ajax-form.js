// how to use it:
// Add this line to the view with the form
// STRIPEMETRICS.ajaxform.init(Rails.env,'form[data-async]');
// 
if (!STRIPEMETRICS) var STRIPEMETRICS = { };

STRIPEMETRICS.ajaxform = function() {

    var _verbose = false;

    var log = function(msg) {
        if (_verbose == true ) { console.log(msg) };
    };

    // ---------------------------------------------------
    // public function(s)
    // ---------------------------------------------------
    return  {

        init: function(environment,selector) { 
            if (environment == 'development') { _verbose = true };
            if (typeof console == 'undefined') { _verbose = false };

            var selected = jQuery(selector);
            if (typeof selected !== 'undefined') {
                selected.on('submit', function(event) {
                    var $form = jQuery(this);
                    var $target = jQuery($form.attr('data-target'));

                    jQuery.ajax({
                        type: $form.attr('method'),
                        url: $form.attr('action'),
                        data: $form.serialize(),
                        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
                        success: function(data, status) {
                            $target.html(data);
                        }
                    });

                    event.preventDefault();
                });
            };
        }
    };
}();
