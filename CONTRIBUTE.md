## Contribute Guide

## Requirements

- Ruby 3.1 +
- [Docker](https://docs.docker.com/get-docker/) & [Docker-Compose](https://docs.docker.com/compose)

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
$ docker-compose up

# Session 1:
$ rails db:create
$ rails db:migrate
$ yarn start

# Session 2:
$ rails s
```

## Testing

```bash
$ rails test
```

## Troubleshooting

- On macOS ARM, you may casue an crash error when running `rails s`, just we Webrick instead of Puma.

  ```bash
  $ rails s -u webrick
  ```
