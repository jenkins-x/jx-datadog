#!/bin/bash

DATADOG_API_KEY=$(cat /builder/home/datadog.api.key)
DATADOG_APP_KEY=$(cat /builder/home/datadog.app.key)

terraform init terraform
terraform apply \
	-var "datadog_api_key=$DATADOG_API_KEY" \
	-var "datadog_app_key=$DATADOG_APP_KEY" \
	-input=false -auto-approve terraform
