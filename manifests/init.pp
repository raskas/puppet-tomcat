class tomcat {

  package {
    'java-1.6.0-sun-compat':
      ensure  => 'installed';
    'tomcat6':
      ensure  => 'installed',
      require => [Package['java-1.6.0-sun-compat'],
                  Package['ntc-tomcat-startup'],
                  Package['ntc-tomcat-log4j'],
                  Package['tomcat-native']];
    'tomcat6-admin-webapps':
      ensure  => 'installed';
    'log4j':
      ensure  => 'installed';
    'tanukiwrapper':
      ensure  => 'installed';
    'ntc-tomcat-startup':
      ensure  => 'installed';
    'mysql-connector-java':
      ensure  => 'installed';
    'ntc-tomcat-log4j':
      ensure  => 'installed',
      require => Package['log4j'];
    'jakarta-commons-logging':
      ensure  => 'installed';
    'tomcat-native':
      ensure  => 'installed';
    'ntc-jmx-html-adapter':
      ensure  => 'installed';
  }

  file {
    '/etc/init.d/tomcat6':
      ensure  => absent,
      require => Package['tomcat6'];
    '/etc/rc.d/rc0.d/K20tomcat6':
      ensure  => absent,
      require => Package['tomcat6'];
    '/etc/rc.d/rc1.d/K20tomcat6':
      ensure  => absent,
      require => Package['tomcat6'];
    '/etc/rc.d/rc2.d/K20tomcat6':
      ensure  => absent,
      require => Package['tomcat6'];
    '/etc/rc.d/rc3.d/K20tomcat6':
      ensure  => absent,
      require => Package['tomcat6'];
    '/etc/rc.d/rc4.d/K20tomcat6':
      ensure  => absent,
      require => Package['tomcat6'];
    '/etc/rc.d/rc5.d/K20tomcat6':
      ensure  => absent,
      require => Package['tomcat6'];
    '/etc/rc.d/rc6.d/K20tomcat6':
      ensure  => absent,
      require => Package['tomcat6'];
    '/etc/init.d/build-jar-repo':
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      source  => 'puppet:///modules/tomcat/build-jar-repo',
      require => [Package['ntc-tomcat-log4j'],
                  Package['mysql-connector-java'],
                  Package['jakarta-commons-logging']],
      notify  => Service['build-jar-repo'];
    '/etc/tomcat6/logging.properties':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => 'puppet:///modules/tomcat/logging.properties',
      require => Package['tomcat6'],
  }

  service {
    'build-jar-repo':
      ensure    => running,
      enable    => true,
      hasstatus => true,
      require   => File['/etc/init.d/build-jar-repo'];
  }

  logrotate::file {
    'tomcat6':
      log        => '/var/log/tomcat6/*/tomcat.log',
      options    => ['dateext','daily', 'rotate 130', 'compress', 'missingok', 'create 0644 tomcat tomcat', 'sharedscripts'],
      postrotate => [ '/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true',
                      '/bin/kill -HUP `cat /var/run/rsyslogd.pid 2> /dev/null` 2> /dev/null || true'];
    'soap':
      log        => '/var/log/tomcat6/*/soap.log',
      options    => ['dateext', 'daily', 'rotate 30', 'compress', 'missingok', 'copytruncate'];
    'nbi':
      log        => '/var/log/tomcat6/*/nbi.log',
      options    => ['dateext', 'daily', 'rotate 30', 'compress', 'missingok', 'copytruncate'];
  }
}
