(function(Spine, $){

var Manager = Spine.Controller.Manager = Spine.Class.create();
Manager.include(Spine.Events);

Manager.include({
  addAll: function(){
    var args = Spine.makeArray(arguments);
    for (var i=0; i < args.length; i++) this.add(args[i]);
  },
  
  add: function(controller){
    if ( !controller ) throw("Controller required");
    
    this.bind("change", function(current){
      if (controller == current)
        controller.activate();
      else
        controller.deactivate();
    });
    
    controller.active(this.proxy(function(){
      this.trigger("change", controller);
    }));
  }  
});

Spine.Controller.include({
  active: function(callback){
    (typeof callback == "function") ? this.bind("active", callback) : this.trigger("active");
    return this;
  },
  
  isActive: function(){
    return this.el.hasClass("active");
  },
  
  activate: function(){
    this.el.addClass("active");
    return this;
  },
  
  deactivate: function(){
    this.el.removeClass("active");
    return this;
  }
});

})(Spine, Spine.$);