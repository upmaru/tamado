# Tamado

Tamado is a Rails project and list tracker.

## Setup

Tamado requires PostgreSQL, Ruby 4.0.6, and Node.js 20 or newer.

```sh
bin/setup
```

The setup script installs Ruby and Node dependencies, compiles the daisyUI stylesheet, and prepares the database.

## Development

```sh
bin/dev
```

Open `http://localhost:3000/projects`. Seed sample projects, lists, and items with:

```sh
bin/rails db:seed
```

## Tests and checks

```sh
npm run css:build
bin/rails test
bin/ci
```

The production Docker build compiles the stylesheet before Rails asset precompilation.
