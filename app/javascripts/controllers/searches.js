(function($){

window.Searches = Spine.Controller.create({  
  elements: {
    ".items": "items",
    ".query": "queryEl"
  },
  
  events: {
    "click .item": "click"
  },
  
  proxied: ["render", "query", "checkActive"],
  
  template: function(data){
    return $("#searchTemplate").tmpl(data);
  },
  
  init: function(){
    this.input = $("#sidebar input[type=search]");
    this.input.keyup(this.query);
    this.model = Search.init();
    this.model.bind("change", this.render);
  },
  
  render: function(){
    this.items.html(this.template(this.model.results));
  },
  
  query: function(){
    this.model.query(this.input.val());
    this.queryEl.text(this.input.val())
    this.active();
  },
    
  click: function(e){
    var item = $(e.target).item().record.reload();
    this.App.trigger("change", "nodes", item.node());
  }
});

})(jQuery);