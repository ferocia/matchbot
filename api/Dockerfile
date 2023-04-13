# syntax = docker/dockerfile:experimental

FROM ruby:3.2.2-alpine

ENV RAILS_ENV=production

EXPOSE 80

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

RUN apk add build-base tzdata libc6-compat postgresql14-client postgresql14-dev git

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

COPY . .

CMD ["/bin/sh", "./docker-entrypoint.sh"]
