This is source code of [Ruby China Group](http://ruby-china.org)

## Install

  * You need install *Ruby 1.9.2*, *Rubygems* and *Rails 3.1* first.
  * Install and start *Redis*, *MongoDb*, *memcached*
  
  ```
  cp config/config.yml.default config/config.yml
  cp config/mongoid.yml.default config/mongoid.yml
  cp config/redis.yml.default config/redis.yml
  bundle install
  bundle update rails
  rake assets:precompile
  thin start -O -C config/thin.yml
  ./script/resque start
  ```
  
## Deploy 

  ```
  $ cap deploy
  ```

## OAuth

* be sure to use: http://ruby-china.dev/
* callback url: http://ruby-china.dev/account/auth/github/callback


## 麵包屑

### in controller

    drop_breadcrumb("A Level")
    drop_breadcrumb("B Level")

## Menu    

    render_list :class => "menu" do |li|
      li << link_to("Home", "/")
    end

## Contributors

* [Contributors](https://github.com/huacnlee/ruby-china/contributors)

Thanks [Twitter Bootstrap](http://twitter.github.com/bootstrap)

Forked from [Homeland Project](http://github.com/huacnlee/homeland)
