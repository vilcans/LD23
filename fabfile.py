import re
from fabric.api import task, local, run, abort
from fabric.operations import put


root_re = re.compile(r'^(\s*root\s+)([^;]+)\;', re.MULTILINE)


def get_version():
    """Get the Git hash for the current version."""
    return local('git rev-parse --short HEAD', capture=True)


@task
def upload(version=None):
    """Upload the current version to the server.
    Takes an optional version string as parameter.
    By default uses the Git hash.

    """
    if not version:
        version = get_version()
    print 'uploading version', version
    local('make release')
    target = '/opt/ld23/' + version
    run('mkdir ' + target)
    put('www/publish/*', target)
    print 'Uploaded version', version


@task
def publish(version=None):
    if not version:
        version = get_version()
    run('ln -nfs /opt/ld23/%s /opt/ld23/current' % version)
    print 'Published version', version


@task
def nginx():
    """Install the Nginx config"""
    put('nginx.conf', '/etc/nginx/conf.d/', use_sudo=True)
