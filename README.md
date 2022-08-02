# openshift-nginx-letsencrypt

Automatisk Openshift Letsencrypt fornyelse

Ansible playbooks til deployment findes i /deploy

## Deployment requirements:
sudo pip install openshift

cd deploy

## Brug login med:
K8S_AUTH_USERNAME=
K8S_AUTH_PASSWORD=

eller
K8S_AUTH_API_KEY=

fx
K8S_AUTH_API_KEY="sha256~XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" ansible-playbook deploy-letsencrypt.yml -e "deployenvironment=uat" --ask-vault-pass

## Gyldige "deployenvironment"'s:
- test
- uat
- prod

Vaultkey er i Bitwarden.

## Hører sammen med:

### Python server program, som godkender/afviser certifikater
https://github.com/miracle-as/mint-klientcertifikat

### Nginx proxy som sender trafikken mellem certifikat-serveren, Letsencrypt og applikationen
https://github.com/miracle-as/mint-klientcertifikat-server

### Automatisk Letsencrypt fornyelse i Openshift
https://github.com/miracle-as/openshift-nginx-letsencrypt

