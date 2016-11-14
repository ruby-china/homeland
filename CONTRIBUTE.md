Contribute Guide
----------------

## Requirements

* Ruby 2.3.0 +
* PostgreSQL 9.4 +
* Redis 2.8 +
* Memcached 1.4 +
* ImageMagick 6.5 +
* Elasticsearch 2.0 +

## Install in development

### Vagrant

Install [VirtualBox](https://www.virtualbox.org/) + [Vagrant](https://www.vagrantup.com/), and then:

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
rake environment elasticsearch:import:model CLASS=Page FORCE=y
rake environment elasticsearch:import:model CLASS=Topic FORCE=y
rake environment elasticsearch:import:model CLASS=User FORCE=y
```