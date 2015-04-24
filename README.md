## Ruby China

This is the source code of [Ruby China](http://ruby-china.org) website.

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
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install memcached
brew install redis
brew install mongodb
brew install imagemagick
```

**Ubuntu***

```bash
sudo apt-get install memcached mongodb redis-server imagemagick
```

```bash
git clone https://github.com/ruby-china/ruby-china.git
cd ruby-china
./bin/setup
# Ensure that memcached has started up
rails s
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

Forked from [Homeland Project](https://github.com/huacnlee/homeland)
Theme from [Mediom](https://github.com/huacnlee/mediom)

## License

Copyright (c) 2011-2015 Ruby China

Released under the MIT license:

* [www.opensource.org/licenses/MIT](http://www.opensource.org/licenses/MIT)
