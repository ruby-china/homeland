# NAME:     homeland/homeland
FROM ruby:2.6-alpine

MAINTAINER Jason Lee "https://github.com/huacnlee"
RUN gem install bundler
RUN apk --update add ca-certificates nodejs tzdata imagemagick &&\
  apk add --virtual .builddeps build-base ruby-dev libc-dev openssl linux-headers postgresql-dev \
  libxml2-dev libxslt-dev git curl nginx nginx-mod-http-image-filter nginx-mod-http-geoip &&\
  rm /etc/nginx/conf.d/default.conf

RUN curl https://get.acme.sh | sh

ENV RAILS_ENV "production"
ENV HOMELAND_VERSION "master"
ENV RUBYOPT "W0"

WORKDIR /home/app/homeland

VOLUME /home/app/homeland/plugins

RUN mkdir -p /home/app &&\
  find / -type f -iname '*.apk-new' -delete &&\
  rm -rf '/var/cache/apk/*' '/tmp/*'

ADD Gemfile Gemfile.lock /home/app/homeland/
RUN gem install puma
RUN bundle install --deployment --jobs 20 --retry 5 &&\
  find /home/app/homeland/vendor/bundle -name tmp -type d -exec rm -rf {} +
ADD . /home/app/homeland
ADD ./config/nginx/ /etc/nginx

RUN rm -Rf /home/app/homeland/vendor/cache

RUN bundle exec rails assets:precompile RAILS_ENV=production SECRET_KEY_BASE=fake_secure_for_compile


