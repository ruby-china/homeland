FROM ruby:3.4-alpine

RUN apk update && apk add curl gcc g++ gnupg make build-base ca-certificates socat git htop tzdata imagemagick ruby-dev openssl libpq-dev libxml2-dev libxslt-dev nodejs-current npm yarn cmake clang clang-dev gcompat

RUN curl https://get.acme.sh | sh
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"
ENV RUSTFLAGS="-C target-feature=-crt-static"

RUN gem install bundler && \
    bundle config set --local path vendor/bundle

WORKDIR /rails
