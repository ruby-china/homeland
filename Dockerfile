# NAME:     homeland/homeland
FROM homeland/base:3.4-alpine

ENV RAILS_ENV "production"
ENV RUBY_YJIT_ENABLE "true"

WORKDIR /home/app/homeland
VOLUME /home/app/homeland/plugins

RUN mkdir -p /home/app &&\
    rm -rf '/tmp/*' &&\
    rm -rf /etc/nginx/conf.d/default.conf

RUN gem install bundler
ADD Gemfile Gemfile.lock package.json yarn.lock /home/app/homeland/
# Do not enable bundle deployment, use globalize mode, Puma tmp_restart need it.
RUN bundle install && yarn && \
    find /usr/local/bundle -name tmp -type d -exec rm -rf {} + && \
    find /usr/local/bundle -name "*.gem" -type f -exec rm -rf {} + && \
    find /usr/local/lib/ruby -name "*.gem" -type f -exec rm -rf {} + && \
    rm -Rf /usr/local/share/.cache/ && \
    rm -Rf /root/.cargo/registry/cache

ADD . /home/app/homeland
ADD ./config/nginx/ /etc/nginx

RUN bundle exec rails assets:precompile RAILS_PRECOMPILE=1 RAILS_ENV=production SECRET_KEY_BASE=fake
RUN rm -Rf /home/app/homeland/app/javascript && \
    rm -Rf /home/app/homeland/test
