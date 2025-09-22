#!/bin/bash
# Bootstrap script for EC2 instance

# Update package index
sudo apt-get update -y

# Install basic utilities
sudo apt-get install -y curl wget git unzip

# Get the instance ID and write it to a file
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
# echo "Instance ID: $INSTANCE_ID" | sudo tee /var/www/html/instance-id.html

# Install Apache web server
sudo apt-get install -y apache2

# Start and enable Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Create a simple index.html
echo "<h1>Welcome to your Web Two EC2 instance! $INSTANCE_ID </h1>" | sudo tee /var/www/html/index.html