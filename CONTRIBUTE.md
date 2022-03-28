Contribute Guide
----------------

## Requirements

* Ruby 3.1 +
* PostgreSQL 9.4 +
* Redis 2.8 +

## Install in development

### Mac OS X, use Homebrew

```bash
$ brew install redis postgresql imagemagick gs
```

### Ubuntu

```bash
$ sudo apt-get install postgresql postgresql-contrib redis-server imagemagick ghostscript libpq-dev
```

```bash
$ git clone https://github.com/ruby-china/homeland.git
$ cd homeland
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

Installing NPM packages
--------------------------------------------------------------------------------
yarn install v1.22.4
[1/4] 🔍  Resolving packages...
[2/4] 🚚  Fetching packages...
[3/4] 🔗  Linking dependencies...
[4/4] 🔨  Building fresh packages...
✨  Done in 32.20s.
--------------------------------------------------------------------------------

Configure
--------------------------------------------------------------------------------
Your Redis host (default: 127.0.0.1:6379):
--------------------------------------------------------------------------------

Seed default data...                                                      [Done]

== Removing old logs and tempfiles ==

Homeland Successfully Installed.

# Session 1:
$ yarn start

# Session 2:
$ rails s
```

## Testing

```bash
bundle exec rake
```
