define tomcat::instance ( $port              = '8080',
                          $ajpport           = '8009',
                          $debugport         = '9004',
                          $serverport        = '8005',
                          $syslog            = 'LOCAL2',
                          $auth              = '',
                          $java              = '/usr/lib/jvm/java-1.6.0-sun/bin/java',
                          $java_library_path = ['/usr/lib/'],
                          $java_additional   = [],
                          $initmem           = '128',
                          $maxmem            = '512',
                          $enable            = true,
                          $ensure            = 'running') {

  include tomcat

  file {
    # /usr/local/tomcat6-$name directory structure
    "/usr/local/tomcat6-$name":
      ensure  => 'directory',
      owner   => 'tomcat',
      group   => 'tomcat',
      require => Package['tomcat6'],
      before  => [Service["tomcat6-$name"], Service['build-jar-repo']];
    "/usr/local/tomcat6-$name/conf":
      ensure  => 'directory',
      owner   => 'tomcat',
      group   => 'tomcat',
      require => [File["/usr/local/tomcat6-$name"]],
      before  => Service["tomcat6-$name"];
    "/usr/local/tomcat6-$name/webapps":
      ensure  => 'directory',
      owner   => 'tomcat',
      group   => 'tomcat',
      require => [File["/usr/local/tomcat6-$name"]],
      before  => Service["tomcat6-$name"];
    "/usr/local/tomcat6-$name/logs":
      ensure  => 'link',
      target  => "/var/log/tomcat6/$name",
      require => [
        File["/usr/local/tomcat6-$name"],
        File["/var/log/tomcat6/$name"]
      ],
      before  => Service["tomcat6-$name"];
    "/usr/local/tomcat6-$name/temp":
      ensure  => 'link',
      target  => "/var/cache/tomcat6/temp/$name",
      require => [
        File["/usr/local/tomcat6-$name"],
        File["/var/cache/tomcat6/temp/$name"]
      ],
      before  => Service["tomcat6-$name"];
    "/usr/local/tomcat6-$name/work":
      ensure  => 'link',
      target  => "/var/cache/tomcat6/work/$name",
      require => [
        File["/usr/local/tomcat6-$name"],
        File["/var/cache/tomcat6/work/$name"]
      ],
      before  => Service["tomcat6-$name"];
    "/usr/local/tomcat6-$name/work/Catalina":
      ensure  => 'directory',
      owner   => 'tomcat',
      group   => 'tomcat',
      require => File["/usr/local/tomcat6-$name/work"],
      before  => Service["tomcat6-$name"];
    "/usr/local/tomcat6-$name/work/Catalina/localhost":
      ensure  => 'directory',
      owner   => 'tomcat',
      group   => 'tomcat',
      require => File["/usr/local/tomcat6-$name/work/Catalina"],
      before  => Service["tomcat6-$name"];
    # Link destinations outside /usr/local/tomcat6-$name
    "/var/log/tomcat6/$name":
      ensure  => 'directory',
      owner   => 'tomcat',
      group   => 'tomcat',
      mode    => '0755',
      require => Package['tomcat6'],
      before  => Service["tomcat6-$name"];
    "/var/cache/tomcat6/temp/$name":
      ensure  => 'directory',
      owner   => 'tomcat',
      group   => 'tomcat',
      require => Package['tomcat6'],
      before  => Service["tomcat6-$name"];
    "/var/cache/tomcat6/work/$name":
      ensure  => 'directory',
      owner   => 'tomcat',
      group   => 'tomcat',
      require => Package['tomcat6'],
      before  => Service["tomcat6-$name"];
    # Files inside /usr/local/tomcat6-$name/conf/
    "/usr/local/tomcat6-$name/conf/log4j.properties":
      owner   => 'tomcat',
      group   => 'tomcat',
      content => template('tomcat/log4j.properties.erb'),
      require => [File["/usr/local/tomcat6-$name/conf"]],
      notify  => Service["tomcat6-$name"];
    "/usr/local/tomcat6-$name/conf/server.xml":
      owner   => 'tomcat',
      group   => 'tomcat',
      content => template('tomcat/server.xml.erb'),
      require => [File["/usr/local/tomcat6-$name/conf"]],
      notify  => Service["tomcat6-$name"];
    "/usr/local/tomcat6-$name/conf/web.xml":
      owner   => 'tomcat',
      group   => 'tomcat',
      source  => 'puppet:///modules/tomcat/web.xml',
      require => [File["/usr/local/tomcat6-$name/conf"]],
      notify  => Service["tomcat6-$name"];
    "/usr/local/tomcat6-$name/conf/wrapper.conf":
      owner   => 'tomcat',
      group   => 'tomcat',
      content => template('tomcat/wrapper.conf.erb'),
      require => [File["/usr/local/tomcat6-$name/conf"]],
      notify  => Service["tomcat6-$name"];
    "/usr/local/tomcat6-$name/conf/wrapper.conf.debug":
      owner   => 'tomcat',
      group   => 'tomcat',
      content => template('tomcat/wrapper.conf.debug.erb'),
      require => [File["/usr/local/tomcat6-$name/conf"]],
      notify  => Service["tomcat6-$name"];
    # Init script
    "/etc/init.d/tomcat6-$name":
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template('tomcat/tomcat6-init.erb'),
      require => [Package['tomcat6'], Package['tanukiwrapper']];
  }

  # If $ensure is explicitly set to an empty string,
  # we won't mention ensure in the service definition.
  # This means that it won't be stopped or started by puppet
  if $ensure != '' {
    service {
      "tomcat6-$name":
        ensure  => $ensure,
        enable  => $enable,
        require => [
          File["/etc/init.d/tomcat6-$name"],
          Service['build-jar-repo']
        ];
    }
  } else {
    service {
      "tomcat6-$name":
        enable  => $enable,
        require => [
          File["/etc/init.d/tomcat6-$name"],
          Service['build-jar-repo']
        ];
    }
  }
  File['/etc/tomcat6/logging.properties']~>Service["tomcat6-$name"]
}

