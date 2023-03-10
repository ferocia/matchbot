# matchbot

## Local Development

### Setup Environment

From the root of the project:

```
asdf install
```

Ensure your database is running:

```
pg_ctl start
```

### Setup API

From the root of the project:

```
cd api
bundle

bundle exec rails db:setup
```

### Setup Web

From the root of the project:

```
cd web
yarn
```

### Running the server

From the root of the project:

```
overmind s
```
