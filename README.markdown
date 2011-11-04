This is source code of [Ruby China Group](http://ruby-china.org)

## Install

  * You need install *Ruby 1.9.2*, *Rubygems* and *Rails 3.1* first.
  * Install *Redis*, *MongoDb* 
  
  ```
  cp config/config.yml.default config/config.yml
  cp config/mongoid.yml.default config/mongoid.yml
  cp config/redis.yml.default config/redis.yml
  bundle install
  bundle update rails
  rake assets:precompile
  thin start -O -C config/thin.yml
  ./run_resque
  ```
  
## Deploy 

  ```
  $ cap deploy
  ```

## Contributors

* [Jason Lee](http://github.com/huacnlee)
* [Qiu Yun](http://github.com/qiuyun8m)

Thanks [Twitter Bootstrap](http://twitter.github.com/bootstrap)

Forked from [Homeland Project](http://github.com/huacnlee/homeland)
