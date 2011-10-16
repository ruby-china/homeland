var Chat = exports = Spine.Model.setup("Chat", ["content", "author", "node_id", "created_at"]);

Chat.extend(Spine.Model.Ajax);

Chat.include({  
  validate: function(){
    if ( !this.node_id )
      return "node_id required";
  },
  
  node: function(){
    return Node.find(this.node_id);
  },
  
  forNode: function(record){
    if ( !record ) return false;
    return(this.node_id === record.id);
  },
  
  isPaste: function(){
    return this.content.match(/\r|\n/);
  }
});

//= require <models/search>
Chat.extend(Search.Model);
Chat.search_attributes = ["content"];