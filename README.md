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

## Dev-Quickstart

Installing elixir: [see instructions here](http://elixir-lang.org/install.html#unix-and-unix-like)


Install dependencies

    $ mix deps.get

Run tests

    $ mix test

Run linter

    $ mix dogma
