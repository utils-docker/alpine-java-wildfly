FROM fabioluciano/alpine-base-java
LABEL Description="Alpine Java Wildfly" Maintainer="Fábio Luciano <fabio@naimporta.com>"

ARG wildfly_version="9.0.1.Final"
ARG wildfly_url="http://download.jboss.org/wildfly/${wildfly_version}/wildfly-${wildfly_version}.tar.gz"

ENV JBOSS_HOME=/opt/wildfly \
    PATH=$PATH:$JBOSS_HOME

WORKDIR /opt/

COPY files/supervisor/* /etc/supervisor.d/
COPY files/scripts/* /usr/local/bin

RUN apk --update --no-cache add \
  && curl -L ${wildfly_url} > wildfly.tar.gz && directory=$(tar tfz wildfly.tar.gz --exclude '*/*') \
  && tar -xzf wildfly.tar.gz && rm wildfly.tar.gz && mv $directory wildfly \
  && echo 'JAVA_OPTS="$JAVA_OPTS -Duser.timezone=America/Sao_Paulo -Duser.country=BR -Duser.language=pt"' >> /opt/wildfly/bin/standalone.conf \
  && /opt/wildfly/bin/add-user.sh admin admin --silent=true \
  && mv /opt/wildfly/standalone/configuration /opt/wildfly/standalone/_configuration \
  && chmod a+x -R /usr/local/bin/* \
  && rm -rf /var/cache/apk/*

WORKDIR /opt/wildfly/standalone

VOLUME ["/opt/wildfly/standalone/deployments/", "/opt/wildfly/standalone/tmp/", "/opt/wildfly/standalone/data/", "/opt/wildfly/standalone/logs/"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 8080/tcp 8443/tcp 9990/tcp
