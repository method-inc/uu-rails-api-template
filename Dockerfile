FROM alpine:3.2
MAINTAINER Glenn Goodrich <glenn.goodrich@skookum.com>

ENV BUILD_PACKAGES curl-dev ruby-dev build-base openssl-dev libxml2-dev libxslt-dev libgcrypt libffi-dev git ncurses tzdata postgresql-dev xvfb
ENV RUBY_PACKAGES ruby ruby-irb ruby-json ruby-rake ruby-io-console ruby-bundler ruby-bigdecimal nodejs

# Update the package manager
RUN apk update && \
    apk upgrade && \
    apk add bash $BUILD_PACKAGES && \
    apk add bash $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

EXPOSE 3000

WORKDIR /tmp
COPY Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install

RUN mkdir /app

ADD . /app
WORKDIR /app

CMD ["rails", "server", "-b", "0.0.0.0"]
