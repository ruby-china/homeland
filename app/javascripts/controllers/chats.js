(function($){
  
window.ChatsItem = Spine.Controller.create({
  tag: "li",
  
  proxied: ["render", "remove"],
  
  template: function(data){
    return $("#chatTemplate").tmpl(data);
  },
  
  init: function(){
    this.item.bind("update", this.render);
    this.item.bind("destroy", this.remove);
  },
  
  render: function(item){
    if (item) this.item = item;
    var elements = this.template(this.item);
    this.el.replaceWith(elements);
    this.el = elements;
    this.el.autolink();
    this.el.mailto();
    return this;
  },
  
  remove: function(){
    this.el.remove();
  }
})

window.Chats = Spine.Controller.create({
  elements: {
    ".items": "items",
    ".new textarea": "input"
  },
  
  events: {
    "click .new button": "create",
    "keydown .new textarea": "checkCreate",
  },
  
  proxied: ["changeNode", "addNew", "addOne", "render"],
  
  handle: $("meta[name=handle]").attr("content"),
  
  init: function(){
    Chat.bind("create", this.addNew);
    Chat.bind("refresh", this.render);
    this.App.bind("change:nodes", this.changeNode);
  },
  
  render: function(){
    this.addAll();
    this.delay(function(){
     this.scrollToBottom();
     this.focus();
    });
  },
  
  create: function(){
    if (!this.node)
      throw "Node required";
      
    var value = this.input.val();
    if ( !value ) return false;
    Chat.create({
      author:       this.handle,
      node_id: this.node.id, 
      content: value,
      created_at: new Date()
    });
    
    this.input.val("");
    this.input.focus();
    return false;
  },
  
  changeNode: function(node){
    this.node = node;
    this.render();
    this.active();
  },
  
  focus: function(){
    this.input.focus()
  },
  
  // Private
  
  checkCreate: function(e){
    if (e.which == 13 && !e.shiftKey) {
      this.create();
      return false;
    }
  },
  
  isScrolledToBottom: function(){
    var scrollBottom  = this.items.attr("scrollHeight") -
                        this.items.scrollTop() - 
                        this.items.outerHeight();
    return scrollBottom == 0;
  },
  
  scrollToBottom: function(){
    this.items.scrollTop(
      this.items.attr("scrollHeight")
    );
  },
  
  scroll: function(callback){
    var shouldScroll = this.isScrolledToBottom();
    callback.apply(this);
    if (shouldScroll) 
      this.scrollToBottom();
  },
  
  addOne: function(item, audio){    
    // Chat for a different node
    if ( !item.forNode(this.node) )
      return;

    var msgItem = ChatsItem.init({item: item});
    this.items.append(msgItem.render().el);
    
    if (audio) $.playAudio("/audio/new.mp3");
  },
  
  addAll: function(){
    this.items.empty();
    Chat.each(this.addOne);
  },
  
  addNew: function(item){
    this.scroll(function(){
      this.addOne(item, true);
    });
  },
  
  getItems: function(){
    if ( !this.node ) return [];
    return this.node.chats();
  }
});

})(jQuery);