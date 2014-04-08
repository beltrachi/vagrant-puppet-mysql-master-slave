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
      'log_bin'         => 'mysql-bin',
      'server-id'       => '1',
      'bind_address'    => '192.168.30.100'
    }
  },
  users => {
    'repl@%' => {
       ensure           => 'present',
       password_hash    => mysql_password('repl')
    },
    'root@192.168.30.1' => {
       ensure => 'present'
    }
  },
  grants => {
    'repl@%/*.*' => {
        ensure      => 'present',
        options     => ['GRANT'],
        privileges  => ['REPLICATION SLAVE'],
        table       => '*.*',
        user        => 'repl@%'
    },
    'root@192.168.30.1' => {
       ensure => 'present',
       options => ['GRANT'],
       privileges => ['ALL'],
       table => '*.*',
       user => 'root@192.168.30.1'
    }
  }
}
