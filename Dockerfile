FROM registry.redhat.io/ubi8/ubi
MAINTAINER Team OSI@Miracle A/S <osi@miracle.dk>

RUN wget https://dl.eff.org/certbot-auto && chmod +x certbot-auto

RUN ./certbot-auto --nginx

#RUN dnf install certbot -y && dnf clean all
#RUN mkdir /etc/letsencrypt

CMD ["/entrypoint.sh"]

COPY secret-patch-template.json /
COPY deployment-patch-template.json /
COPY entrypoint.sh /
