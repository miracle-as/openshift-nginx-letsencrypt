FROM registry.redhat.io/ubi8/ubi
#FROM registry.redhat.io/rhel9/python-39
MAINTAINER Team OSI@Miracle A/S <osi@miracle.dk>

RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN rpm -ivh https://vault.centos.org/centos/8/BaseOS/x86_64/os/Packages/python3-configobj-5.0.6-11.el8.noarch.rpm
RUN dnf -y install certbot python39 openssl3
RUN mkdir -p /opt/letsencrypt && chmod 775 /opt/letsencrypt

#RUN mkdir /etc/letsencrypt

CMD ["/entrypoint.sh"]

COPY secret-patch-template.json /
COPY deployment-patch-template.json /
COPY entrypoint.sh /
