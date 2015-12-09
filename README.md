## Ruby China

This is the source code of [Ruby China](http://ruby-china.org) website.

[![Build Status](https://travis-ci.org/ruby-china/ruby-china.svg?branch=master)](https://travis-ci.org/ruby-china/ruby-china)

## Requirements

* Ruby 2.2.0 +
* Memcached 1.4 +
* Redis 2.2 +
* MongoDb 2.4.4 +
* ImageMagick 6.5+

## Install in development

### Vagrant

Install VirtualBox:

https://www.virtualbox.org/

Install Vagrant:

https://www.vagrantup.com/

Then:

```bash
$ vagrant up
$ vagrant ssh
$ cd /vagrant
/vagrant $ ./bin/setup
/vagrant $ rails s -b 0.0.0.0
```

Open http://localhost:3000 in host.

### Mac OS X, use Homebrew

```bash
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
$ brew install memcached
$ brew install redis
$ brew install mongodb
$ brew install imagemagick
$ brew install gs
```

### Ubuntu

```bash
$ sudo apt-get install memcached mongodb redis-server imagemagick ghostscript
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
bundle exec rake
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
