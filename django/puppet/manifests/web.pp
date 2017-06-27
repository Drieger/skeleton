# Helper modules

$PROJECT_NAME = 'project'
$DB_USER  = 'projectowner'
$DB_PASS  = 'projectowner'
$DB_NAME  = 'projectdb'
$APP_NAME = 'app'

Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

exec { "apt-update":
  command => "/usr/bin/apt-get update",
  require => File['/etc/environment']
}

file { '/etc/environment':
	content => inline_template("APP_NAME=${APP_NAME}\nDB_PASS=${DB_PASS}\nDB_USER=${DB_USER}\nDB_NAME=${DB_NAME}\nPROJECT_NAME=${PROJECT_NAME}")
}

class { 'python':
  ensure     => present,
  version    => 'python3',
  pip        => latest,
  virtualenv => latest,
  require    => Exec['apt-update'],
}

python::virtualenv { "/home/ubuntu/${PROJECT_NAME}/.env":
  ensure  => present,
  version => '3',
}

# Python packages
python::pip { 'django':
  pkgname    => Django,
  ensure     => latest,
  timeout    => 1800,
  virtualenv => "/home/ubuntu/${PROJECT_NAME}/.env"
}

python::pip { 'psycopg2':
  pkgname    => psycopg2,
  ensure     => latest,
  timeout    => 1800,
  virtualenv => "/home/ubuntu/${PROJECT_NAME}/.env"
}

python::pip { 'django-restframework':
  pkgname    => djangorestframework,
  ensure     => latest,
  timeout    => 1800,
  virtualenv => "/home/ubuntu/${PROJECT_NAME}/.env"
}

python::pip { 'django-restframework-jwt':
  pkgname    => djangorestframework-jwt,
  ensure     => latest,
  timeout    => 1800,
  virtualenv => "/home/ubuntu/${PROJECT_NAME}/.env"
}

python::pip { 'django-extensions':
  pkgname    => django-extensions,
  ensure     => latest,
  timeout    => 1800,
  virtualenv => "/home/ubuntu/${PROJECT_NAME}/.env"
}

python::pip { 'ipython':
  pkgname    => ipython,
  ensure     => latest,
  timeout    => 1800,
  virtualenv => "/home/ubuntu/${PROJECT_NAME}/.env"
}

# Postgresql configuration
class { 'postgresql::server':
  ip_mask_deny_postgres_user => '0.0.0.0/32',
  ip_mask_allow_all_users    => '0.0.0.0/0',
  listen_addresses           => '*',
  postgres_password          => 'postgres',
  require                    => Exec['apt-update']
}

postgresql::server::db { "${DB_NAME}":
  user     => "${DB_USER}",
  password => postgresql_password("${DB_USER}", "${DB_PASS}"),
}

postgresql::server::database_grant { $DB_NAME:
  privilege => 'ALL',
  db        => $DB_NAME,
  role      => $DB_USER,
}

# Run script that actually creates the project
file { "/home/ubuntu/${PROJECT_NAME}/scripts/new-project.sh":
  ensure => 'file',
  mode   => '0755',
}

exec { 'create-project-script':
  command     => "/bin/bash -c /home/ubuntu/${PROJECT_NAME}/scripts/new-project.sh",
  creates     => "/home/ubuntu/${PROJECT_NAME}/app/",
  user        => 'ubuntu',
  environment => ['HOME=/home/ubuntu'],
}

file { "/home/ubuntu/${PROJECT_NAME}/app/app/settings.py":
  ensure => file,
  source => ["file:///home/ubuntu/${PROJECT_NAME}/puppet/files/settings.py"]
}

file { "/home/ubuntu/${PROJECT_NAME}/app/assets":
  ensure => 'directory',
  require => Exec['create-project-script']
}


Class['python'] -> Python::Virtualenv<| |> -> Python::Pip<| |> -> File["/home/ubuntu/${PROJECT_NAME}/scripts/new-project.sh"] -> Exec['create-project-script'] -> File["/home/ubuntu/${PROJECT_NAME}/app/app/settings.py"]
