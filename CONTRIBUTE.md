Contribute Guide
----------------

## Requirements

* Ruby 2.4.0 +
* PostgreSQL 9.4 +
* Redis 2.8 +
* MeiliSearch 0.9.1 +

## Install in development

### Mac OS X, use Homebrew

```bash
$ brew install redis postgresql imagemagick gs meilisearch
```

### Ubuntu

```bash
$ sudo apt-get install postgresql postgresql-contrib redis-server imagemagick ghostscript libpq-dev
```

Install MeiliSearch

```bash
./bin/meilisearch
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

Configure
--------------------------------------------------------------------------------
Your Redis host (default: 127.0.0.1:6379):
Your MeiliSearch host (default: 127.0.0.1:7700):
--------------------------------------------------------------------------------

Seed default data...                                                      [Done]

== Removing old logs and tempfiles ==

Homeland Successfully Installed.

$ rails s
```

## Testing

```bash
bundle exec rake
```

## Reindex Search Indexes

```bash
rails search:reindex
```
