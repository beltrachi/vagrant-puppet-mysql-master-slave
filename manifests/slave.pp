exec { "apt-update":
    command => "/usr/bin/apt-get update"
}

Exec["apt-update"] -> Package <| |>

group { "puppet":
  ensure => "present",
}

class { '::mysql::server':
  override_options => {
    'mysqld' => {
      'server-id' => '2',
      'bind_address'    => '192.168.30.101'
    }
  },
  users => {
    'root@192.168.30.1' => {
       ensure => 'present'
    }
  },
  grants => {
    'root@192.168.30.1' => {
       ensure => 'present',
       options => ['GRANT'],
       privileges => ['ALL'],
       table => '*.*',
       user => 'root@192.168.30.1'
    }
  }
}
