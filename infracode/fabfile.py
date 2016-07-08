#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
\x1b[31mYmir Automation:\x1b[0m
  This is the \x1b[35mExlasticLB\x1b[0m Service
"""
import os
from fabric import api
from ymir import load_service_from_json

YMIR_SERVICE_JSON = os.path.abspath(
    os.environ.get(
        'YMIR_SERVICE_JSON',
        os.path.join(os.path.dirname(__file__),
                     'service.json')))

# Create the ymir service from the service description
service = load_service_from_json(YMIR_SERVICE_JSON)

# Install the standard service operations
# (like create, terminate, provision, etc) as fabric commands
service.fabric_install()

src_root = os.path.dirname(os.path.dirname(__file__))
from ymir import data as ydata
ELIXIR_ROLE = "jacoelho.elixir"

@api.task
def provision_elixir():
    with service.ssh_ctx():
        elixir_present = service.run("which elixir").succeeded
        if elixir_present:
            service.report_success("elixir is already installed on remote")
        else:
            service.report_failure("elixir is not installed on the remote")
            service._provision_ansible_role(ELIXIR_ROLE)

@api.task
def deploy():
    """ deploy exlastlb code to remote """
    branch = api.local('git rev-parse --abbrev-ref HEAD', capture=True)
    service.report('deploy for branch "{0}" -> {1} '.format(
        branch, service))
    with api.lcd(src_root):
        api.local('mix escript.build')
        bin_name = "exlasticlb"
        config_name = 'config.json'
        service_defaults = service.template_data()['service_defaults']
        bin_dest = service_defaults['lb_daemon_upload_path']
        config_dest = service_defaults['lb_config_upload_path']
        service.put(os.path.join(src_root, bin_name),
                    os.path.dirname(bin_dest))
        service.put(os.path.join(src_root,config_name),
                    os.path.dirname(config_dest))
        service.run("chmod ogo+x {0}".format(bin_dest))
        service.sudo("sudo service supervisor restart")


@api.task
def tail_syslog():
    """ example: tail syslog on remote server """
    with service.ssh_ctx():
        api.sudo('tail /var/log/syslog')
