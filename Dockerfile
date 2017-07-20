FROM fabioluciano/alpine-base-java
MAINTAINER Fábio Luciano <fabioluciano@php.net>
LABEL Description="Alpine Java Wildfly"

ARG wildfly_version
ENV wildfly_version ${wildfly_version:-"10.1.0.Final"}

ARG wildfly_username
ENV wildfly_username ${wildfly_username:-"wildfly"}

ARG wildfly_password
ENV wildfly_password ${wildfly_password:-"password"}

ARG install_dir
ENV install_dir ${install_dir:-"/opt/wildfly"}

ENV wildfly_url "http://download.jboss.org/wildfly/${wildfly_version}/wildfly-${wildfly_version}.tar.gz"

################

RUN apk --update --no-cache add openssh

WORKDIR /opt

## Configure SSH
RUN printf "${wildfly_password}\n${wildfly_password}" | adduser ${wildfly_username} \
  && printf "\n\n" | ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
  && printf "\n\n" | ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \
  && printf "\n\n" | ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
  && printf "\n\n" | ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key \
  && echo "AllowUsers ${wildfly_username}" >> /etc/ssh/sshd_config

## Configure Wildfly
RUN curl -L ${wildfly_url} > wildfly.tar.gz \
  && directory=$(tar tfz wildfly.tar.gz --exclude '*/*') \
  && tar -xzf wildfly.tar.gz && rm wildfly.tar.gz \
  && mv $directory wildfly \
  && echo 'JAVA_OPTS="$JAVA_OPTS -Duser.timezone=America/Sao_Paulo -Duser.country=BR -Duser.language=pt"' >> ${install_dir}/bin/standalone.conf \
  && echo 'JAVA_OPTS="$JAVA_OPTS -Dorg.apache.coyote.http11.Http11Protocol.COMPRESSION=on"' >> ${install_dir}/bin/standalone.conf \
  && echo 'JAVA_OPTS="$JAVA_OPTS -Dorg.apache.coyote.http11.Http11Protocol.COMPRESSION_MIME_TYPES=application/atom+xml,application/javascript,application/json,application/ld+json,application/manifest+json,application/rdf+xml,application/rss+xml,application/schema+json,application/vnd.geo+json,application/vnd.ms-fontobject,application/x-font-ttf,application/x-javascript,application/x-web-app-manifest+json,application/xhtml+xml,application/xml,font/eot,font/opentype,image/bmp,image/svg+xml,image/vnd.microsoft.icon,image/x-icon,text/cache-manifest,text/css,text/html,text/javascript,text/plain,text/vcard,text/vnd.rim.location.xloc,text/vtt,text/x-component,text/x-cross-domain-policy,text/xml"' >> ${install_dir}/bin/standalone.conf \
  && echo 'JAVA_OPTS="$JAVA_OPTS -Dorg.apache.coyote.http11.Http11Protocol.COMPRESSION_MIN_SIZE=20"' >> ${install_dir}/bin/standalone.conf \
  && chown ${wildfly_username}:${wildfly_username} /opt/wildfly -R \
  && mkdir -p /var/log/sshd/ /var/log/wildfly/

COPY files/supervisor/* /etc/supervisor.d/

EXPOSE 8080/tcp 8443/tcp 9990/tcp
