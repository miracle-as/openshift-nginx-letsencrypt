FROM registry.redhat.io/ubi8/ubi
MAINTAINER Team OSI@Miracle A/S <osi@miracle.dk>

RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && dnf -y config-manager --set-enabled PowerTools
RUN dnf -y install certbot python3-certbot-nginx

#RUN mkdir /etc/letsencrypt

CMD ["/entrypoint.sh"]

COPY secret-patch-template.json /
COPY deployment-patch-template.json /
COPY entrypoint.sh /
