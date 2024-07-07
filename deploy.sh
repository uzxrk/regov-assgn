#!/bin/bash

ENV=$1

if [ "$ENV" == "dev" ] || [ "$ENV" == "qa" ] || [ "$ENV" == "uat" ] || [ "$ENV" == "prod" ]; then
  echo "Deploying to $ENV environment..."

  # Initialize and apply Terraform
  terraform -chdir=terraform/$ENV init &&
  terraform -chdir=terraform/$ENV apply -auto-approve &&

  # Get the IP address of the provisioned instance
  INSTANCE_IP=$(terraform -chdir=terraform/$ENV output -raw my_app_instance_ip)

  echo "Transferring files to $INSTANCE_IP..."
  rsync -avz --exclude='node_modules' --exclude='.git' . ubuntu@$INSTANCE_IP:/var/www/my-app &&

  echo "Installing dependencies and restarting the application on $INSTANCE_IP..."
  ssh -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << 'EOF'
    cd /var/www/my-app
    npm install --production &&
    pm2 restart my-app || pm2 start app.js --name my-app
EOF
else
  echo "Unknown environment: $ENV"
  exit 1
fi
