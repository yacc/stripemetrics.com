if (!STRIPEMETRICS) var STRIPEMETRICS = { };

STRIPEMETRICS.job_control = function() {

	var _verbose = false;

	var log = function(msg) {
		if (_verbose == true ) { console.log(msg) };
	};

	var start_job = function(type) {
		jQuery.ajax({
			url : 'jobs/start',
			dataType : 'json',
			data: { type: type }
		});
	};



	// ---------------------------------------------------
	// public function(s)
	// ---------------------------------------------------
	return  {

		init: function(environment,element,type) { 
			if (environment == 'development') { _verbose = true };
			if (typeof console == 'undefined') { _verbose = false };

			jQuery(element).click(function(){
				start_job(type);
			});
		}


	};

}();
