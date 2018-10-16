FROM ruby:2.5-alpine

MAINTAINER Jason Lee "https://github.com/huacnlee"

RUN gem install bundler
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk --update add ca-certificates tzdata imagemagick nodejs nginx nginx-mod-http-image-filter nginx-mod-http-geoip &&\
    apk add --virtual .builddeps build-base ruby-dev libc-dev openssl linux-headers postgresql-dev \
    libxml2-dev libxslt-dev curl git &&\
    curl https://get.acme.sh | sh &&\
    rm /etc/nginx/conf.d/default.conf

WORKDIR /home/app/homeland

ENV RAILS_ENV "production"
ENV HOMELAND_VERSION "master"

ADD Gemfile Gemfile.lock ./
RUN bundle install --deployment --clean --without development test --jobs 20 --retry 5 &&\
    find ./vendor/bundle -name tmp -type d -exec rm -rf {} +
ADD . .
ADD ./config/nginx/ /etc/nginx

RUN bundle exec rails assets:precompile RAILS_ENV=production SECRET_KEY_BASE=fake_secure_for_compile

RUN rm -Rf /home/app/homeland/vendor/cache &&\
    rm -Rf /home/app/homeland/tmp/* &&\
    rm -Rf /home/app/homeland/vendor/bundle/ruby/*/cache &&\
    rm -Rf /home/app/homeland/.git &&\
    rm -Rf /root/.bundle/cache &&\
    rm -Rf /usr/local/lib/ruby/gems/*/cache &&\
    chown -R nginx:nginx /home/app &&\
    apk del .builddeps &&\
    find / -type f -iname '*.apk-new' -delete &&\
    rm -rf '/var/cache/apk/*' '/tmp/*'



