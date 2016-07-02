## Preqrequisite infrastructure


Installing terraform: [see instructions here](https://www.terraform.io/intro/getting-started/install.html)

    $ mkdir ~/.aws/
    $ touch ~/.aws/credentials

In the `~/.aws/credentials` file, add something like this (profile name must be 'samble'):

    [samble]
    aws_access_key_id = your_access_key
    aws_secret_access_key = your_secret_key

Show infrastructure plan:

    $ terraform plan infracode

Build infrastructure in AWS:

    $ terraform apply infracode

## Dev-Quickstart

Installing elixir: [see instructions here](http://elixir-lang.org/install.html#unix-and-unix-like)

### Install dependencies

    $ mix deps.get

### Run tests

    $ mix test --cover

### Run linter

    $ mix dogma

### Run static analysis

The first time you have to build the [persistent lookup table](https://github.com/jeremyjh/dialyxir#plt), which takes a while.

    $ mix dialyzer.plt

Thereafter, just run

    $ mix dialyzer
