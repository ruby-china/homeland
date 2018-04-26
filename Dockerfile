# NAME:     homeland/homeland
FROM homeland/base:1.0.1
MAINTAINER Jason Lee "https://github.com/huacnlee"

ENV RAILS_ENV 'production'

ENV HOMELAND_VERSION 'master'

RUN useradd ruby -s /bin/bash -m -U &&\
    mkdir -p /var/www &&\
    cd /var/www
ADD . /var/www/homeland
RUN cd /var/www/homeland && bundle install --deployment &&\
    find /var/www/homeland/vendor/bundle -name tmp -type d -exec rm -rf {} + &&\
    chown -R ruby:ruby /var/www

WORKDIR /var/www/homeland
