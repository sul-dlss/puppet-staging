# Define staging::deploy::warfile
#
#   Uses staging::file to grab a warfile from the given source, and copies it as the warfile param to
#   tomcat::catalina_home/webapps (e.g., /var/lib/tomcat6/webapps)
#
# Note:
#   It will only work with tomcat6 at the moment
#    
# Usage:
#
#  staging::deploy::warfile { 'myapp.war':
#    source => '/tmp/myapp.war'
#    warfile => 'myapp.war',
#  }
#
define staging::deploy::warfile (
  $source,
  $warfile,                # name of the warfile placed into the webapps directory 
  $staging_path = undef,
  # staging file settings:
  $username     = undef,
  $certificate  = undef,
  $password     = undef,
  $environment  = undef,
  $timeout      = undef,
  # allowing pass through of real caller.
  $subdir      = $caller_module_name,
  $reload      = undef
){

  include tomcat
  include staging

  staging::file { $name:
    source      => $source,
    target      => $staging_path,
    username    => $username,
    certificate => $certificate,
    password    => $password,
    environment => $environment,
    subdir      => $caller_module_name,
    timeout     => $timeout,
  }
 
  file { "${tomcat::catalina_home}/webapps/${warfile}":
    owner       => 'tomcat',
    group       => 'tomcat',
    source      => "${staging::path}/${subdir}/${name}",
    require     => Staging::File[$name],
  }

  if $reload {
    $path = regsubst($warfile, '(.*).war', '\1')
    exec { "reload ${path}":
        command => "${tomcat::manager_script} reload /${path}";
    }
  }
}
