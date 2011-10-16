Array.makeArray = function(value){
  if ( !value ) return [];
  if ( typeof value == "string" ) return [value];
  return Array.prototype.slice.call(value, 0);
};

Array.prototype.include = function(value){
  return(this.indexOf(value) != -1);
};

Array.prototype.intersect = function(array){
  return(this.filter(function(n){ return array.include(n); }));
};

Array.prototype["delete"] = function(value){
  return(this.filter(function(n){ return n != value; }));
};

Array.prototype.any = function(){
  return(this.length > 0);
};