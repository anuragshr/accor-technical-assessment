#If you want to run both modules together, you can use this script to run terraform commands in both modules.

#!/bin/bash

code=("infrastructure" "helm")
action=$1

if [ $action == "create" ]; then
    for code in "${code[@]}"; do
        cd $code && terraform init -upgrade && terraform plan && terraform apply -auto-approve && cd ..
    done

elif [ $action == "destroy" ]; then
        cd infrastructure && terraform destroy -auto-approve && cd ..
else
  echo "Invalid action. Please specify 'create' or 'destroy'."
  exit 1
fi