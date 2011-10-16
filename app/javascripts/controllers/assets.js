//= require <jquery.drop>
//= require <jquery.upload>

(function($){

window.Assets = Spine.Controller.create({
  proxied: ["drop"],
  
  handle: $("meta[name=handle]").attr("content"),
  
  init: function(){
    if ( !this.chats )
      throw("`chats` option required");
    
    $("#wrapper").dropArea().bind("drop", this.drop);
  },
  
  drop: function(e){
    e.stopPropagation();
    e.preventDefault();
    e = e.originalEvent;
    
    var files = e.dataTransfer.files;
    for ( var i = 0; i < files.length; i++)
      this.upload(files[i]);
  },
  
  upload: function(file){
    if ( !this.chats.node ) return;
    
    var chat = Chat.create({
      author:       this.handle,
      body:       "Uploading " + file.name,
      node_id: this.chats.node.id
    });
        
    $.upload("/assets", {file: file}, {
      dataType: "json",
      
      upload: {
        progress: function(e){
          Spine.Model.noSync(function(){
            var per = Math.round((e.position / e.total) * 100);
            chat.updateAttributes({per: per});
          });
        }
      }
    }).success(function(data){
      chat.updateAttributes({
        body: file.name + ": " + data.url
      });
    });
  }
});

})(jQuery);