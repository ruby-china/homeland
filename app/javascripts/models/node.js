var Node = exports = Spine.Model.setup("Node", ["name"]);

Node.extend(Spine.Model.Ajax);

Node.include({
  chats: function(){
    var node_id = this.id;
    return Chat.select(function(m){ 
      return m.node_id == node_id; 
    });
  },
  
  validate: function(){
    if (!this.name)
      return "name is required";
  }
});