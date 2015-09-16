## JStack

This is the source code of [JStack](http://jstack.io) website.

[![Build
Status](https://secure.travis-ci.org/ruby-china/ruby-china.png?branch=master&.png)](http://travis-ci.org/ruby-china/ruby-china)

## Requirements

* Ruby 2.2.0 +
* Memcached 1.4 +
* Redis 2.2 +
* MongoDb 2.4.4 +
* ImageMagick 6.5+

## Install in development


**Mac OS X, use Homebrew**

```bash
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
$ brew install memcached
$ brew install redis
$ brew install mongodb
$ brew install imagemagick
```

**Ubuntu***

```bash
$ sudo apt-get install memcached mongodb redis-server imagemagick
```

```bash
$ git clone https://github.com/ruby-china/ruby-china.git
$ cd ruby-china
$ ./bin/setup
Checking Package Dependencies...
--------------------------------------------------------------------------------
MongoDB 2.0+                                                               [Yes]
Redis 2.0+                                                                 [Yes]
Memcached 1.4+                                                             [Yes]
ImageMagick 6.5+                                                           [Yes]
--------------------------------------------------------------------------------

Installing dependencies
--------------------------------------------------------------------------------
The Gemfile's dependencies are satisfied
--------------------------------------------------------------------------------

Configure
--------------------------------------------------------------------------------
Your MongoDB host (default: 127.0.0.1:27017):
Your Redis host (default: 127.0.0.1:6379):
--------------------------------------------------------------------------------

Seed default data...                                                      [Done]

== Removing old logs and tempfiles ==

Ruby China Successfully Installed.

$ rails s
```

## Testing

```bash
bundle exec rspec spec
```

## Contributors

* [Contributors](https://github.com/ruby-china/ruby-china/contributors)

## Thanks

* [Twitter Bootstrap](https://twitter.github.com/bootstrap)
* [Font Awesome](http://fortawesome.github.io/Font-Awesome/icons/)
* [Google Roboto Font](https://github.com/google/roboto)

Forked from [Homeland Project](https://github.com/huacnlee/homeland)
Theme from [Mediom](https://github.com/huacnlee/mediom)

## Sites

* [Ruby China](https://ruby-china.org)
* [36kr](http://36kr.com/)
* [Testhome](http://testerhome.com/)

## License

Copyright (c) 2011-2015 Ruby China

Released under the MIT license:

* [www.opensource.org/licenses/MIT](http://www.opensource.org/licenses/MIT)
