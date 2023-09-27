#! /bin/bash

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Create folders for FDO installation and TLS certificates
mkdir /fdo
mkdir /fdo/certs

# Install AWS CLI
sudo apt-get -y update
sudo apt-get -y install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp/
sudo /tmp/aws/install

# Prepare license and certificates
aws s3 cp s3://dmitry-fdo-test-bucket/cert.pem /fdo/certs/
aws s3 cp s3://dmitry-fdo-test-bucket/key.pem /fdo/certs/
cp /fdo/certs/cert.pem /fdo/certs/bundle.pem
aws s3 cp s3://dmitry-fdo-test-bucket/terraform.hclic /fdo/
