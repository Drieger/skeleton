# Helper modules
Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

exec { "apt-update":
  command => "/usr/bin/apt-get update"
}

class { 'python':
  ensure     => present,
  version    => 'python3',
  pip        => latest,
  virtualenv => latest,
}

python::virtualenv { '/home/ubuntu/project/.env':
  ensure  => present,
  version => '3',
}

# Python packages
python::pip { 'django':
  pkgname    => Django,
  ensure     => latest,
  timeout    => 1800,
  virtualenv => '/home/ubuntu/project/.env'
}

python::pip { 'psycopg2':
  pkgname    => psycopg2,
  ensure     => latest,
  timeout    => 1800,
  virtualenv => '/home/ubuntu/project/.env'
}

python::pip { 'django-restframework':
  pkgname    => djangorestframework,
  ensure     => latest,
  timeout    => 1800,
  virtualenv => '/home/ubuntu/project/.env'
}

python::pip { 'django-extensions':
  pkgname    => django-extensions,
  ensure     => latest,
  timeout    => 1800,
  virtualenv => '/home/ubuntu/project/.env'
}

python::pip { 'ipython':
  pkgname    => ipython,
  ensure     => latest,
  timeout    => 1800,
  virtualenv => '/home/ubuntu/project/.env'
}

# Postgresql configuration
class { 'postgresql::server':
  ip_mask_deny_postgres_user => '0.0.0.0/32',
  ip_mask_allow_all_users    => '0.0.0.0/0',
  listen_addresses           => '*',
  postgres_password          => 'postgres',
}

postgresql::server::db { 'projectdb':
  user     => 'projectowner',
  password => postgresql_password('projectowner', 'projectowner'),
}

postgresql::server::database_grant { 'projectdb':
  privilege => 'ALL',
  db        => 'projectdb',
  role      => 'projectowner',
}
