FROM registry.redhat.io/ubi9/ubi
MAINTAINER Team OSI@Miracle A/S <osi@miracle.dk>

RUN dnf install certbot -y && dnf clean all
RUN mkdir /etc/letsencrypt

CMD ["/entrypoint.sh"]

COPY secret-patch-template.json /
COPY deployment-patch-template.json /
COPY entrypoint.sh /
