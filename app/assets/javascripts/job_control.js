if (!STRIPEMETRICS) var STRIPEMETRICS = { };

STRIPEMETRICS.job_control = function() {

	var _verbose = false;

	var log = function(msg) {
		if (_verbose == true ) { console.log(msg) };
	}

	var start_job = function() {
		jQuery.ajax({url : 'jobs/start', dataType : 'json'});
	}



	// ---------------------------------------------------
	// public function(s)
	// ---------------------------------------------------
	return  {

		init: function(environment,element) { 
			if (environment == 'development') { _verbose = true };
			if (typeof console == 'undefined') { _verbose = false };

			jQuery(element).bind('click', start_job);
		},


	};

}();
