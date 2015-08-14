Mongoid::Document.send :include, Mongoid::BaseModel
Mongoid::Document.send :include, Mongoid::WillPaginate
Mongoid::Criteria.send :include, Mongoid::WillPaginate
