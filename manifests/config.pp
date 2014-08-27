# == Class: kibana::configure
#
# This class configures kibana.  It should not be directly called.
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
#
# === Copyright
#
# Copyright 2013 EvenUp.
#
class kibana::config (
  $es_host            = '',
  $es_port            = 9200,
  $modules            = [ 'histogram','map','table','filtering','timepicker',
                        'text','fields','hits','dashcontrol','column',
                        'derivequeries','trends','bettermap','query','terms' ],
  $logstash_logging   = false,
  $default_board      = 'default.json',
  $docroot            = '/var/www/html/kibana',
  $apache_vhost_hash  = {}
) {

  $es_real = $es_host ? {
    ''      => "http://'+window.location.hostname+':${es_port}",
    default => "http://${es_host}:${es_port}"
  }

  file { 'kibana_config':
    path    => "${docroot}/config.js",
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('kibana/config.js'),
  }

  $default_vhost_hash = {
    'kibana' => {
      'docroot'     => $docroot,
      'port'        => '80',
      'vhost_name'  => $::fqdn,
    }
  }

  $merged_vhost_hash = merge($default_vhost_hash, $apache_vhost_hash)

  create_resources('apache::vhost', $merged_vhost_hash)

  if $default_board != 'default.json' {
    file { "${docroot}/app/dashboards/default.json":
      ensure  => link,
      target  => "{$docroot}/app/dashboards/${default_board}",
      force   => true,
    }
  }
}
