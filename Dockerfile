# NAME:     homeland/homeland
FROM homeland/base:3.0.1-slim-buster

ENV RAILS_ENV "production"
ENV RUBYOPT "W0"

WORKDIR /home/app/homeland

VOLUME /home/app/homeland/plugins

RUN mkdir -p /home/app &&\
  rm -rf '/tmp/*' &&\
  rm -rf /etc/nginx/conf.d/default.conf

ADD Gemfile Gemfile.lock package.json yarn.lock /home/app/homeland/
# Do not enable bundle deployment, use globalize mode, Puma tmp_restart need it.
RUN bundle install && yarn &&\
  find /usr/local/bundle -name tmp -type d -exec rm -rf {} + && \
  find /usr/local/bundle -name "*.gem" -type f -exec rm -rf {} +
ADD . /home/app/homeland
ADD ./config/nginx/ /etc/nginx

RUN bundle exec rails assets:precompile RAILS_PRECOMPILE=1 RAILS_ENV=production SECRET_KEY_BASE=fake_secure_for_compile
RUN rm -Rf /home/app/homeland/app/javascript && \
  rm -Rf /home/app/homeland/test

