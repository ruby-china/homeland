(function($){

window.Sidebar = Spine.Controller.create({
  events: {
    "click [data-name]": "click"
  },
  
  elements: {
    "#nodes": "nodes"
  },
  
  proxied: ["change", "render"],
  
  template: function(item){
    return $("#nodesTemplate").tmpl(item);
  },
  
  init: function(){
    Node.bind("refresh change", this.render);
    this.App.bind("change", this.change);
  },
  
  render: function(){
    var items    = Node.all();
    this.nodes.html(this.template(items));
    
    // Select first node
    if ( !this.current )
      this.$("[data-name=nodes]:first").click();
  },
  
  change: function(type, item){
    this.App.trigger("change:" + type, item);

    this.deactivate();
    var elements = this.$("[data-name=" + type + "]");    
    this.current = (item && elements.forItem(item)) || elements;
    this.current.addClass("current");    
  },
  
  click: function(e){
    var element = $(e.target);
    var type = element.attr("data-name");
    var item = element.item();
    this.App.trigger("change", type, item);
  },
  
  deactivate: function(){
    this.$("[data-name]").removeClass("current");    
  }  
});

})(jQuery);