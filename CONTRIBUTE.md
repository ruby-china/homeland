Contribute Guide
----------------

## Requirements

* Ruby 2.4.0 +
* PostgreSQL 9.4 +
* Redis 2.8 +
* Memcached 1.4 +
* Elasticsearch 2.0 +

## Install in development

### Mac OS X, use Homebrew

```bash
$ brew install memcached redis postgresql imagemagick gs elasticsearch
```

### Ubuntu

```bash
$ sudo apt-get install memcached postgresql postgresql-contrib redis-server imagemagick ghostscript
```

Install Elasticsearch

```bash
curl -sSL https://git.io/vVHhm | bash
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
Your Elasticsearch host (default: 127.0.0.1:9200):
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

## Reindex ElasticSearch

```bash
rails elasticsearch:import:model CLASS=Page FORCE=y
rails elasticsearch:import:model CLASS=Topic FORCE=y
rails elasticsearch:import:model CLASS=User FORCE=y
```
