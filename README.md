## Ruby China

This is the source code of [Ruby China](http://ruby-china.org) website.

[![Build
Status](https://secure.travis-ci.org/ruby-china/ruby-china.png?branch=master&.png)](http://travis-ci.org/ruby-china/ruby-china)

## Requirements

* Ruby 1.9.3 +
* Memcached 1.4 +
* Redis 2.2+
* MongoDb 2.4.4 +
* ImageMagick 6.5+
* libpng

## Install

```bash
git clone git://github.com/ruby-china/ruby-china.git
cd ruby-china
ruby setup.rb
# ensure that memcached has started up
rails s
```

## Start Sidekiq service

```bash
# Sidekiq
# ensure that redis has started up
bundle exec sidekiq -C config/sidekiq.yml
```

## Testing

```bash
bundle exec rspec spec
```

to prepare all the config files and start essential services.

## JavaScript Testing

Open `/specs` in the browser to see the test result. For example, if your
rails starts at `localhost:3000`, visit http://localhost:3000/specs

### Headless Testing

First install [PhantomJS](http://phantomjs.org/), then run following command:

```bash
RAILS_ENV=test bundle exec rake spec:javascript
```

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
