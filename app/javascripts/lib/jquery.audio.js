(function($){
  
  $.playAudio = function(sources){
    var audio = $("<audio />");
    audio.attr("autobuffer", true);
    sources = $.makeArray(sources);
    $.each(sources, function(){
      audio.append(
        $("<source />").attr("src", this)
      );
    });
    audio[0].play();
  };
  
})(jQuery);