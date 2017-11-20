#! /bin/sh

if [ ! -d /opt/wildfly/standalone/configuration ]; then
  mv /opt/wildfly/standalone/_configuration /opt/wildfly/standalone/configuration
  chown wildfly:wildfly /opt/wildfly/ -R
fi

if [ -d /opt/wildfly/standalone/_configuration ]; then
  rm -rf /opt/wildfly/standalone/_configuration
fi

supervisord --nodaemon -c /etc/supervisord.conf -j /tmp/supervisord.pid -l /var/log/supervisord.log
