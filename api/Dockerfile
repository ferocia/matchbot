# syntax = docker/dockerfile:experimental

FROM ruby:3.2

ENV RAILS_ENV=production

EXPOSE 80

RUN apt-get update -qq && apt-get install -y postgresql-client

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

COPY . .

CMD ["./docker-entrypoint.sh"]
