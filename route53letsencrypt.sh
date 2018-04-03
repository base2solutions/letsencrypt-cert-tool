#!/bin/bash

#Test to see if the secret exists in Docker Datacenter. If so, set the environment variables.
if [ -f /run/secrets/AWS_ACCESS_KEY_ID ] && [ -f /run/secrets/AWS_SECRET_ACCESS_KEY ]; then
  export AWS_ACCESS_KEY_ID=$(cat /run/secrets/AWS_ACCESS_KEY_ID)
  export AWS_SECRET_ACCESS_KEY=$(cat /run/secrets/AWS_SECRET_ACCESS_KEY)
fi

#Test to see if the AWS Environment variables have been set. If not, exit.
if [[ -z "${AWS_ACCESS_KEY_ID}" ]] || [[ -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
  echo "AWS Environment variables have not been set. Please set AWS_ACCCESS_KEY_ID and AWS_SECRET_ACCESS_KEY."
  exit 1
fi

#Test to see if cert registration email has been set. If not, exit.
if [[ -z "${CERTBOT_EMAIL}" ]]; then
  echo "Certbot registration email environment variable has not been set. Please set CERTBOT_EMAIL."
  exit 1
fi

if [ -z $CERTBOT_DOMAIN ]; then
  mkdir -p $PWD/letsencrypt

  certbot certonly \
      --non-interactive \
      --manual \
      --agree-tos \
      --manual-public-ip-logging-ok \
      --email ${CERTBOT_EMAIL} \
      --manual-auth-hook $0 \
      --manual-cleanup-hook $0 \
      --preferred-challenge dns \
      --config-dir $PWD/letsencrypt \
      --work-dir $PWD/letsencrypt \
      --logs-dir $PWD/letsencrypt \
      $@

else
  [[ $CERTBOT_AUTH_OUTPUT ]] && ACTION="DELETE" || ACTION="UPSERT"

  printf -v QUERY 'HostedZones[?!(Config.PrivateZone)&&ends_with(`%s.`,Name)].Id' $CERTBOT_DOMAIN

  HOSTED_ZONE_ID=$(aws route53 list-hosted-zones --query $QUERY --output text)

  if [ -z $HOSTED_ZONE_ID ]; then
    echo "No hosted zone found that matches $CERTBOT_DOMAIN"
    exit 1
  fi

  aws route53 wait resource-record-sets-changed --id $(
    aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE_ID \
    --query ChangeInfo.Id --output text \
    --change-batch "{
      \"Changes\": [{
        \"Action\": \"$ACTION\",
        \"ResourceRecordSet\": {
          \"Name\": \"_acme-challenge.$CERTBOT_DOMAIN.\",
          \"ResourceRecords\": [{\"Value\": \"\\\"$CERTBOT_VALIDATION\\\"\"}],
          \"Type\": \"TXT\",
          \"TTL\": 30
        }
      }]
    }"
  )

fi
