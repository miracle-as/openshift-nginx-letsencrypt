# openshift-nginx-letsencrypt

Automatisk Openshift Letsencrypt fornyelse

Ansible playbooks til deployment findes i /deploy

eployment requirements:
sudo pip install openshift

cd deploy

Brug login med:
K8S_AUTH_USERNAME=
K8S_AUTH_PASSWORD=

eller
K8S_AUTH_API_KEY=

fx
K8S_AUTH_API_KEY="sha256~XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" ansible-playbook deploy-server.yml -e "deployenvironment=uat" --ask-vault-pass

Gyldige "deployenvironment"'s:
test
uat
prod

Vaultkey er i Bitwarden.
