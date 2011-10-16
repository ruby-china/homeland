(function($){
  
$.ajaxTransport("+*", function(s){    
  var xhr;
  
  if (s.useXHR2)
    return {
      send: function(headers, complete){   
        xhr = s.xhr();
        xhr.open( s.type, s.url, s.async );
    
        // This needs to be dynamically for the correct multipart boundary
        delete headers["Content-Type"];
        headers[ "X-Requested-With" ] = "XMLHttpRequest";
    
        for ( i in headers ) {
         xhr.setRequestHeader( i, headers[ i ] );
        }
  	
      	var callback = function(e){
      	  var responses = {xml: xhr.responseXML, text: xhr.responseText};
      	  complete( xhr.status, xhr.statusText, responses, xhr.getAllResponseHeaders() );
      	};
  	
      	xhr.addEventListener("load", callback);
      	xhr.addEventListener("error", callback);
  	
        if (s.progress)
          xhr.addEventListener("progress", s.progress);
        if (s.upload && s.upload.success)
          xhr.upload.addEventListener("load", s.upload.load);
        if (s.upload && s.upload.progress)
          xhr.upload.addEventListener("progress", s.upload.progress);

        xhr.send(s.data);
      },
  
      abort: function(){
        if(xhr) xhr.abort();
      }
  };
});

var defaults = {
  processData: false,
  contentType: "multipart/form-data",
  type:        "POST",
  useXHR2:      true,
  upload:      {}
};

$.upload = function(url, data, settings){    
  var fd = new FormData;
  
  if ( data instanceof File )
    data = {"file": data}
  
  for ( var key in data )
    fd.append(key, data[key]);
  
  // Last argument can be success callback
  if ( typeof settings == "function" ) {
    settings = {success: settings};
  }
  
  settings.url  = url;
  settings.data = fd;
  settings = $.extend({}, defaults, settings);
  
  return $.ajax(settings);
};

})(jQuery);