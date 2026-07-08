#!/bin/bash

set -e
source .env
IP=$("$TF" -chdir="../Terraform" output -raw public_ip)
scp -i "$PRIVATE_KEY" nginx-config.txt "$USERNAME@$IP:/tmp/nginx-config.txt"

echo "Connecting to $USERNAME@$IP..."


ssh -i "$PRIVATE_KEY" "$USERNAME@$IP"  <<EOF


sudo apt update
sudo apt install -y nginx



#Copy Config
sudo cp /tmp/nginx-config.txt /etc/nginx/sites-available/app
echo "Nginx Configuration Copied"

#Enabled site 
sudo ln -sf /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app
sudo rm -f /etc/nginx/sites-enabled/default
# Test 
if sudo nginx -t; then
   echo "Configuration is valid"
   sudo systemctl reload nginx
   echo " nginx reloaded"
else 
   echo "ERROR in configuration"
fi

 
echo "======================"
echo "====Docker_install===="
echo "======================"
sudo apt install -y docker.io 
sudo docker pull "$IMAGE"

sudo docker stop "$CONTAINER_NAME" || true
sudo docker rm "$CONTAINER_NAME" || true

sudo docker run -d \
  --name "$CONTAINER_NAME" \
  -p 127.0.0.1:$HOST_PORT:$CONTAINER_PORT \
  "$IMAGE"

EOF