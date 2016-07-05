## Preqrequisite infrastructure

See `infracode/README.md`.

## Dev-Quickstart

Installing elixir: [see instructions here](http://elixir-lang.org/install.html#unix-and-unix-like)

### Install dependencies

    $ mix deps.get

### Run tests

    $ mix test --cover

## Compile commandline

    $ mix escript.build

## Run commandline

   $ ./exlasticlb --config config.json

### Run linter

    $ mix dogma

### Run static analysis

The first time you have to build the [persistent lookup table](https://github.com/jeremyjh/dialyxir#plt), which takes a while.

    $ mix dialyzer.plt

Thereafter, just run

    $ mix dialyzer
