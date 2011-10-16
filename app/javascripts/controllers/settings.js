(function($){
  
var Nodes = Spine.Controller.create({
  tag: "li",
  
  proxied: ["render", "remove"],
  
  events: {
    "click    .destroy": "destroy",
    "dblclick .view":    "edit",
    "keypress input":    "blurOnEnter",
    "blur     input":    "close"
  },
  
  elements: {
    "input": "input"
  },
  
  init: function(){
    this.item.bind("update", this.render);
    this.item.bind("destroy", this.remove);
  },
  
  template: function(data){
    return($("#editNodeTemplate").tmpl(data));
  },
  
  render: function(){
    this.el.html(this.template(this.item));
    this.refreshElements();
    return this;
  },
  
  edit: function(){
    this.el.addClass("editing");
    this.input.focus();
  },
  
  blurOnEnter: function(e) {
    if (e.keyCode == 13) e.target.blur();
  },
  
  close: function(){
    this.el.removeClass("editing");
    this.item.updateAttributes({name: this.input.val()});
  },
  
  remove: function(){
    this.el.remove();
  },
  
  destroy: function(){
    if (confirm("Are you sure you want to delete this node?"))
      this.item.destroy();
  }
});

window.Settings = Spine.Controller.create({
  elements: {
    ".nodes": "nodesEl",
    ".createNode input": "input"
  },
  
  events: {
    "submit .createNode form": "create"
  },
  
  proxied: ["addAll", "addOne", "active"],
  
  init: function(){
    Node.bind("refresh", this.addAll);
    Node.bind("create", this.addOne);
    
    this.App.bind("change:settings", this.active);
  },
  
  addOne: function(item){
    var node = Nodes.init({item: item});
    this.nodesEl.append(node.render().el);
  },
  
  addAll: function(){
    this.nodesEl.empty();
    Node.each(this.addOne);
  },
  
  create: function(){
    var value = this.input.val();
    if ( !value ) return false;
    Node.create({name: value});
    this.input.val("");
    return false;
  }
});

})(jQuery);