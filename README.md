## Ruby China

This is the source code of [Ruby China](http://ruby-china.org) website.

[![Build
Status](https://secure.travis-ci.org/ruby-china/ruby-china.png?branch=master&.png)](http://travis-ci.org/ruby-china/ruby-china)

## Requirements

* Ruby 1.9.2+
* Memcached 1.4+
* Redis 2.2+
* Python 2.4+ and [Pygments](http://pygments.org)  - You can run `easy_install pygments` to install it.
* MongoDb 2.0+
* ImageMagick 6.5+
* libpng

## Install

```bash
git clone git://github.com/ruby-china/ruby-china.git
cd ruby-china
ruby setup.rb
rails s
```

## Start Sidekiq service

```bash
# Sidekiq
bundle exec sidekiq -c config/sidekiq.yml
```

## Testing

```bash
bundle exec rspec spec
```

to prepare all the config files and start essential services.

## Apply Google JSAPI

* http://code.google.com/intl/zh-CN/apis/loader/signup.html

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
