# syntax = docker/dockerfile:experimental

FROM ruby:3.2

ENV RAILS_ENV=production

RUN apt-get update -qq && apt-get install -y postgresql-client

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "3000"]
