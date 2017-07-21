FROM fabioluciano/alpine-base-java
MAINTAINER Fábio Luciano <fabioluciano@php.net>
LABEL Description="Alpine Java Wildfly"

ARG wildfly_version
ENV wildfly_version ${wildfly_version:-"8.2.1.Final"}

ARG wildfly_username
ENV wildfly_username ${wildfly_username:-"wildfly"}

ARG wildfly_password
ENV wildfly_password ${wildfly_password:-"password"}

ARG install_dir
ENV install_dir ${install_dir:-"/opt"}

ENV wildfly_url "http://download.jboss.org/wildfly/${wildfly_version}/wildfly-${wildfly_version}.tar.gz"

WORKDIR ${install_dir}

## Configure SSH
RUN apk --update --no-cache add openssh \
  && printf "${wildfly_password}\n${wildfly_password}" | adduser ${wildfly_username} \
  && printf "\n\n" | ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
  && printf "\n\n" | ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \
  && printf "\n\n" | ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
  && printf "\n\n" | ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key \
  && echo "AllowUsers ${wildfly_username}" >> /etc/ssh/sshd_config \
  && curl -L ${wildfly_url} > wildfly.tar.gz && directory=$(tar tfz wildfly.tar.gz --exclude '*/*') \
  && tar -xzf wildfly.tar.gz && rm wildfly.tar.gz && mv $directory wildfly \
  && echo 'JAVA_OPTS="$JAVA_OPTS -Duser.timezone=America/Sao_Paulo -Duser.country=BR -Duser.language=pt"' >> /opt/wildfly/bin/standalone.conf \
  && chown ${wildfly_username}:${wildfly_username} /opt/wildfly -R && mkdir -p /var/log/sshd/ /var/log/wildfly/ \
  && /opt/wildfly/bin/add-user.sh admin admin --silent=true && rm -rf /var/cache/apk/* \
  && keytool -genkey -alias containerized_application -keysize 2048 -validity 1825 -keyalg RSA -keystore keystore.jks \
    -dname "CN=Container de Aplicacao, OU=Fabrica de Software, O=CTIS Tecnologia S/A, L=Brasilia, ST=Distrito Federal, C=BR" \
    -storepass password -keypass password

COPY files/supervisor/* /etc/supervisor.d/

EXPOSE 8080/tcp 8443/tcp 9990/tcp
