## Ruby-China 

This is the source code of [Ruby China](http://ruby-china.org) website.

[![Build
Status](https://secure.travis-ci.org/ruby-china/ruby-china.png?branch=master&.png)](http://travis-ci.org/ruby-china/ruby-china)

## Install

  * You need *Ruby 1.9.2+*, *Rubygems* and *Rails 3.2+* first.
  * Install and start *Redis*, *MongoDB*, *memcached*, *Python*, *Pygments*

and run:

    cp config/config.yml.default config/config.yml
    cp config/mongoid.yml.default config/mongoid.yml
    cp config/redis.yml.default config/redis.yml
    bundle install
    rake assets:precompile
    rake db:seed
    thin start -O -C config/thin.yml
    ./script/resque start
    bundle exec rake sunspot:solr:start
    easy_install pygments # 或者 pip install pygments
    rake db:migrate

or you can just this issue 


    rake test:init

to prepare all the config files and start essential services.

## Deploy

    $ cap deploy
    $ cap production remote_rake:invoke task=db:setup

# Apply Google JSAPI

* http://code.google.com/intl/zh-CN/apis/loader/signup.html

## Memcached

Dalli requires memcached 1.4.x +

## Contributors

* [Contributors](https://github.com/ruby-china/ruby-china/contributors)

## Thanks

* [Twitter Bootstrap](https://twitter.github.com/bootstrap)
* [GentleFace Icons](http://www.gentleface.com/free_icon_set.html)

Forked from [Homeland Project](https://github.com/huacnlee/homeland)

## License

Copyright (c) 2011-2012 Ruby China

Released under the MIT license:

* [www.opensource.org/licenses/MIT](http://www.opensource.org/licenses/MIT)
