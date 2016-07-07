## Preqrequisite infrastructure
** Installing AWS credentials **

In the `~/.aws/credentials` file, add something like this (profile name must be 'samble'):

    [exlasticlb]
    aws_access_key_id = your_access_key
    aws_secret_access_key = your_secret_key

**Installing ymir**

    $ pip install ymir
    $ ymir version


## Creating a load-balancer instance with ymir

Full documentation for ymir is [here](http://mattvonrocketstein.github.io/ymir).

To begin, you must always work inside the `infracode` folder and specify the AWS profile being used.  The name is not important but it must match what you created in the previous section.  Second, since ymir can manage multiple hosts, you should specify the configuration JSON you want to work with.

    $ cd infracode
    $ export AWS_PROFILE="exlasticlb"
    $ export YMIR_SERVICE_JSON="load_balancer.json"

At this point, you might like to validate the infracode

    $ ymir validate

To create the load-balancer server:

    $ fab create

Now setup infracode dependencies (like ansible libraries), and provision the load-balancer server with elixir.

    $ fab setup
    $ fab provision

At this point you should be ready to deploy exlasticlb and it's configuration:

    $ fab deploy:exlastic_config.json

To confirm that all is well, run the system checks:

    $ fab check

## Creating test hosts to place beneath the load balancer

The steps are basically the same as the load-balancer steps, except that you'll need different values for YMIR_SERVICE_JSON, and the deploy command takes no arguments.

    $ cd infracode
    $ export AWS_PROFILE="exlasticlb"
    $ export YMIR_SERVICE_JSON="hostXXX.json"
    $ fab create && fab setup provision
    $ fab deploy
    $ fab check

To create load on the test servers and influence the choice of the load-balancer, run:

    $ fab stress
