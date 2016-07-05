## Preqrequisite infrastructure

**Installing terraform:** [see instructions here](https://www.terraform.io/intro/getting-started/install.html)

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
