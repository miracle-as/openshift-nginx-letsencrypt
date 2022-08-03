#!/bin/bash

if [[ -z $EMAIL || -z $DOMAINS || -z $SECRET || -z $DEPLOYMENT ]]; then
	echo "EMAIL, DOMAINS, SECERT, and DEPLOYMENT env vars required"
	env
	exit 1
fi

# Do certificate needs renewing?
DAYSBEFORE=30 # Letsencrypt recommend automatically renewing your certificates every 60 days
expire=$(date -d "$(cat /opt/app-root/src/ssl/..data/server.crt | openssl3 x509 -noout -enddate | cut -d'=' -f2)" +%s)
now=$(date -d "now" +%s)
datediff=$(($expire-$now))
renewsec=$((DAYSBEFORE*86400))
if [ "$datediff" -gt "$renewsec" ]; then
  echo "Certificate doesn't require renewing. Expires in " $(( $datediff / 86400 )) " days"
  exit 0
fi


NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)

WEBHOME=/opt/letsencrypt/web
mkdir -p $WEBHOME
cd $WEBHOME
python3 -m http.server 8080 &
PID=$!
certbot certonly --webroot -w $WEBHOME -n --agree-tos --email ${EMAIL} --no-self-upgrade -d ${DOMAINS} --config-dir /opt/letsencrypt/config/ --work-dir /opt/letsencrypt/work/ --logs-dir /opt/letsencrypt/logs/ $OPTS
kill $PID

CERTPATH=/opt/letsencrypt/config/live/$(echo $DOMAINS | cut -f1 -d',')

ls $CERTPATH || exit 1

cat /secret-patch-template.json | \
	sed "s/NAMESPACE/${NAMESPACE}/" | \
	sed "s/NAME/${SECRET}/" | \
	sed "s/TLSCERT/$(cat ${CERTPATH}/fullchain.pem | base64 | tr -d '\n')/" | \
	sed "s/TLSKEY/$(cat ${CERTPATH}/privkey.pem |  base64 | tr -d '\n')/" \
	> /opt/letsencrypt/secret-patch.json

ls /opt/letsencrypt/secret-patch.json || exit 1

# update secret
curl -v --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -k -v -XPATCH  -H "Accept: application/json, */*" -H "Content-Type: application/strategic-merge-patch+json" -d @/opt/letsencrypt/secret-patch.json https://api-int:6443/api/v1/namespaces/${NAMESPACE}/secrets/${SECRET}

cat /deployment-patch-template.json | \
	sed "s/TLSUPDATED/$(date)/" | \
	sed "s/NAMESPACE/${NAMESPACE}/" | \
	sed "s/NAME/${DEPLOYMENT}/" \
	> /opt/letsencrypt/deployment-patch.json

ls /opt/letsencrypt/deployment-patch.json || exit 1

# update pod spec on ingress deployment to trigger redeploy
curl -v --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -k -v -XPATCH  -H "Accept: application/json, */*" -H "Content-Type: application/strategic-merge-patch+json" -d @/opt/letsencrypt/deployment-patch.json https://api-int:6443/apis/apps.openshift.io/v1/namespaces/${NAMESPACE}/deploymentconfigs/${DEPLOYMENT}
