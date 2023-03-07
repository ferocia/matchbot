# syntax = docker/dockerfile:experimental

FROM node:16

ENV NODE_ENV=production

RUN apt-get update -qq && apt-get install -y nginx

WORKDIR /app

COPY docker/nginx.conf /etc/nginx/sites-enabled/default

COPY package.json /app/package.json
COPY yarn.lock /app/yarn.lock
RUN yarn install

COPY . .

RUN yarn build

EXPOSE 80

CMD ["./docker/entrypoint.sh"]
