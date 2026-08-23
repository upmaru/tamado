# Tamado

Tamado is a Rails project and list tracker.

## Setup

Tamado requires PostgreSQL, Ruby 4.0.6, and Node.js 20 or newer.

```sh
bin/setup
```

The setup script installs Ruby and daisyUI dependencies, compiles the Tailwind stylesheet, and prepares the database.

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
bin/rails tailwindcss:build
bin/rails test
bin/ci
```

Tailwind compilation is integrated with Rails asset precompilation and test preparation.
