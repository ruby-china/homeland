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

## Bookstrap CSS version

1.4.0 

## Bootstrap Form 

<https://github.com/rafaelfranca/simple_form-bootstrap/blob/master/config/initializers/simple_form.rb>

## Memcached

Dalli need memcached 1.4.x +

## Helpers

    render_topic_title(topic)
## Common Partial

* common/share : for social share
* common/user\_nav : user\_navigation_bar

## Styling Guide

* Don't put plain html in helper
* NEVER LOGIC in View
* 重複用到的方法請隨手用 Helper 包
* 永遠使用括號 () 包覆複雜 Helper

## Contributors

* [Contributors](https://github.com/huacnlee/ruby-china/contributors)

Thanks [Twitter Bootstrap](http://twitter.github.com/bootstrap), Icons from [Iconic](http://dictionary.reference.com/browse/iconic)

Forked from [Homeland Project](http://github.com/huacnlee/homeland)
