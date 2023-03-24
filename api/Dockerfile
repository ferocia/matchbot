# syntax = docker/dockerfile:experimental

FROM ruby:3.2

ENV RAILS_ENV=production

EXPOSE 80

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

RUN apt-get update -qq && apt-get install -y postgresql-client

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

COPY . .

CMD ["./docker-entrypoint.sh"]
