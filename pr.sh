#!/bin/bash

DATADOG_API_KEY=$(cat /builder/home/datadog.key)

terraform init terraform
terraform plan \
	-var "datadog_api_key=$DATADOG_API_KEY" \
	-input=false terraform
