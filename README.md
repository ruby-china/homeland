## Ruby China

This is the source code of [Ruby China](http://ruby-china.org) website.

[![Build Status](https://travis-ci.org/ruby-china/ruby-china.svg?branch=master)](https://travis-ci.org/ruby-china/ruby-china) [![Code Climate](https://codeclimate.com/github/ruby-china/ruby-china/badges/gpa.svg)](https://codeclimate.com/github/ruby-china/ruby-china) [![codecov.io](https://codecov.io/github/ruby-china/ruby-china/coverage.svg?branch=master)](https://codecov.io/github/ruby-china/ruby-china?branch=master)

## Requirements

* Ruby 2.3.0 +
* Memcached 1.4 +
* Redis 2.8 +
* PostgreSQL 9.4 +
* ImageMagick 6.5+
* Elasticsearch 2.0+

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
$ brew install postgresql
$ brew install imagemagick
$ brew install gs
$ brew install elasticsearch
```

### Ubuntu

```bash
$ sudo apt-get install memcached postgresql-9.4 redis-server imagemagick ghostscript
```

More details about install PostgreSQL

http://www.postgresql.org/download/linux/ubuntu/

Install Elasticsearch

```bash
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
sudo apt-get update && sudo apt-get install elasticsearch openjdk-7-jre-headless
sudo update-alternatives --config java
# 选择 java-7
```

```bash
$ git clone https://github.com/ruby-china/ruby-china.git
$ cd ruby-china
$ ./bin/setup
Checking Package Dependencies...
--------------------------------------------------------------------------------
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
Your Redis host (default: 127.0.0.1:6379):
Your Elasticsearch host (default: 127.0.0.1:9200):
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

## About Emoji Asset files

You may see emoji files 404 not found, after you publish you app. Because the emoji not include into Assets Pipline, what reason you can read Issue #522.

You need upload emoji images into `/assets/emojis` production environment path / CDN path, you can find image here: [md_emoji](https://github.com/elm-city-craftworks/md_emoji/tree/master/vendor/assets/images/emojis)

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
