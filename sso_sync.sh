#!/bin/bash +x

WORKDIR="."
SSOSYNC="$WORKDIR/ssosync"
GoogleCredentials="$WORKDIR/credentials.json"
DOMAIN="creditninja.com"

echo "Check script requirements.."
if [ $(which aws) ] && [ $(which jq) ]; then
  echo -n "OK" && echo
else 
  echo " Install jq and aws-cli"
  exit 1
fi

echo "Getting credentials.."
SCIMEndpointAccessToken=$(aws secretsmanager get-secret-value --secret-id SSOSyncSCIMAccessToken | jq -r '.SecretString')
SCIMEndpointUrl=$(aws secretsmanager get-secret-value --secret-id SSOSyncSCIMEndpointUrl | jq -r '.SecretString')
GoogleAdminEmail=$(aws secretsmanager get-secret-value --secret-id  SSOSyncGoogleAdminEmail | jq -r '.SecretString')
aws secretsmanager get-secret-value --secret-id SSOSyncGoogleCredentials | jq -r '.SecretString' | jq > $GoogleCredentials

echo "Syncing.."
$SSOSYNC \
  --access-token "$SCIMEndpointAccessToken" \
  --endpoint "$SCIMEndpointUrl" \
  --google-admin  "$GoogleAdminEmail" \
  --google-credentials "$GoogleCredentials" \
  --sync-method "users_groups" \
  --include-groups "sso_database_admin@$DOMAIN" \
  --include-groups "sso_developer@$DOMAIN" \
  --include-groups "sso_developer_lead@$DOMAIN" \
  --include-groups "sso_devops@$DOMAIN" \
  --include-groups "sso_qa@$DOMAIN" \
  --include-groups "sso_risk_analyst@$DOMAIN" \
  --include-groups "sso_risk_developer@$DOMAIN" \
  --debug

#  --include-groups "sso_database_admin@$DOMAIN,sso_developer@$DOMAIN,sso_developer_lead@$DOMAIN,sso_devops@$DOMAIN,sso_qa@$DOMAIN,sso_risk_analyst@$DOMAIN,sso_risk_developer@$DOMAIN" \
