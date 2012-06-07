## Ruby-China

This is the source code of [Ruby China](http://ruby-china.org) website.

[![Build
Status](https://secure.travis-ci.org/ruby-china/ruby-china.png?branch=master&.png)](http://travis-ci.org/ruby-china/ruby-china)

## Install

* You need *Ruby 1.9.2+*, *Rubygems* and *Rails 3.2+* first.
* Install and start *Redis*, *MongoDB*, *memcached*, *Python*, *Pygments*

and run:

```bash
easy_install pygments # 或者 pip install pygments
cp config/config.yml.default config/config.yml
cp config/mongoid.yml.default config/mongoid.yml
cp config/redis.yml.default config/redis.yml
cp config/thin.yml.default config/thin.yml
bundle install
bundle exec rake db:migrate
bundle exec rake db:seed
bundle exec sidekiq -c config/sidekiq.yml
bundle exec rake sunspot:solr:start
rails s
```

or you can just this issue

```bash
bundle exec rspec spec
```

to prepare all the config files and start essential services.

## Deploy

```bash
$ cap deploy
$ cap production remote_rake:invoke task=db:setup
```

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
