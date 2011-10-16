var Search = Spine.Class.create();
Search.include(Spine.Events);

Search.models = [];

Search.Model = {
  extended: function(){
    Search.models.push(this);
  }
};

Search.Record = Spine.Class.create({
  init: function(value, record){
    this.value  = value;
    this.record = record;
  },
  
  reload: function(){
    return this;
  }
});

Search.include({
  init: function(){
    this.proxyAll("queryModel", "queryRecord");
    this.results = [];
  },
  
  query: function(params){
    this.clear();
    if ( !params ) return;
    this.params = params.toLowerCase();
    this.parent.models.forEach(this.queryModel);
    this.trigger("change");
  },
    
  clear: function(){
    this.results = [];
    this.trigger("change");
  },
  
  each: function(callback){
    this.results.forEach(callback);
  },
  
  // Private
  
  queryModel: function(model){
    var each  = model.search_each || model.each;
    each.call(model, this.queryRecord);
  },
  
  queryRecord: function(record) {
    var attributes = (record.search_attributes || record.attributes).apply(record);
    
    for (var key in attributes) {      
      var value = (attributes[key] + "").toLowerCase();
      
      if (value.indexOf(this.params) != -1)
        this.results.push(Search.Record.init(value, record));
    }
  }
});