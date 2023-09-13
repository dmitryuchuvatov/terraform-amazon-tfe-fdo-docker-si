# Terraform Enterprise Flexible Deployment Options - Docker


# Prerequisites
Install Terraform as per [official documentation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

AWS account

[TFE FDO license](https://license.hashicorp.services/)

# How To

## Clone repository

```
git clone https://github.com/dmitryuchuvatov/fdo-es-docker.git
```

## Change folder

```
cd fdo-es-docker
```

## Open *terraform.tfvars* and change the values per your requirements

## Set AWS credentials

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_SESSION_TOKEN=
```

## Terraform init
```
terraform init
```

## Terraform apply

```
terraform apply
```

When prompted, type **yes** and hit **Enter** to start provisioning AWS infrastructure.

You should see the similar result:

```
Apply complete! Resources: 27 added, 0 changed, 0 destroyed.

Outputs:

ssh_login    = "ssh -i tfesshkey.pem ubuntu@dmitry-fdo-es.tf-support.hashicorpdemo.com"
tfe_hostname = "https://dmitry-fdo-es.tf-support.hashicorpdemo.com"
```

## Installing TFE FDO Beta

# SSH into the new instance

Copy the SSH login command from the above-mentioned Output, paste it into the Terminal and hit Enter. Type Y and hit Enter again.

```
ssh -i tfesshkey.pem ubuntu@dmitry-fdo-es.tf-support.hashicorpdemo.com
```

# Generate and upload the certificates

Run the following commands to generate CA-signed certificates:

```
sudo snap install --classic certbot

sudo ln -s /snap/bin/certbot /usr/bin/certbot

sudo certbot certonly --standalone
```


Follow the instructions to obtain the certificates (enter your email address; Y; N; enter domain name):

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Enter email address (used for urgent renewal and security notices)
(Enter 'c' to cancel): dmitry.uchuvatov@hashicorp.com

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.3-September-21-2022.pdf. You must
agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: N
Account registered.
Please enter the domain name(s) you would like on your certificate (comma and/or
space separated) (Enter 'c' to cancel): dmitry-fdo-es.tf-support.hashicorpdemo.com    
Requesting a certificate for dmitry-fdo-es.tf-support.hashicorpdemo.com

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/dmitry-fdo-es.tf-support.hashicorpdemo.com/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/dmitry-fdo-es.tf-support.hashicorpdemo.com/privkey.pem
This certificate expires on 2023-12-12.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.
```

Then, create a new directory dedicated for TFE FDO-Beta installation files, and change into it:

```
mkdir fdo
cd fdo
```

Create a certs directory, and change into it:

```
mkdir certs
cd certs
```

Copy the certificates into certs directory:

```
sudo bash
cp /etc/letsencrypt/live/dmitry-fdo-es.tf-support.hashicorpdemo.com/* ./
```

Run the following commands to adjust their names according to requirements:

```
cp privkey.pem key.pem
cp fullchain.pem cert.pem
cp fullchain.pem bundle.pem
```

# Prepare YAML file

In this example, we will install Terraform Enterprise in External Services mode.

Create a `compose.yaml` file in `fdo` directory and populate it with your desired deployment configuration:

```
---
name: terraform-enterprise
services:
  tfe:
    image: terraform-enterprise-beta.terraform.io/terraform-enterprise:beta-1
    environment:
      TFE_LICENSE: "paste_your_license_here"
      TFE_HOSTNAME: dmitry-fdo-es.tf-support.hashicorpdemo.com
      TFE_ENCRYPTION_PASSWORD: "Password1#"
      TFE_OPERATIONAL_MODE: "external"
      TFE_DISK_CACHE_VOLUME_NAME: ${COMPOSE_PROJECT_NAME}_terraform-enterprise-cache
      TFE_TLS_CERT_FILE: /etc/ssl/private/terraform-enterprise/cert.pem
      TFE_TLS_KEY_FILE: /etc/ssl/private/terraform-enterprise/key.pem
      TFE_TLS_CA_BUNDLE_FILE: /etc/ssl/private/terraform-enterprise/bundle.pem
      TFE_IACT_SUBNETS: 0.0.0.0/0

      # Database settings
      TFE_DATABASE_USER: "postgres"
      TFE_DATABASE_PASSWORD: "Password1#"
      TFE_DATABASE_HOST: "dmitry-fdo-es-postgres.cheg1b8bnf4j.eu-west-2.rds.amazonaws.com"
      TFE_DATABASE_NAME: "fdo"
      TFE_DATABASE_PARAMETERS: "sslmode=disable"

      # Object storage settings
      TFE_OBJECT_STORAGE_TYPE: "s3"
      TFE_OBJECT_STORAGE_S3_REGION: "eu-west-2"
      TFE_OBJECT_STORAGE_S3_BUCKET: "dmitry-fdo-es-bucket"
      TFE_OBJECT_STORAGE_S3_USE_INSTANCE_PROFILE: "true"
    cap_add:
      - IPC_LOCK
    read_only: true
    tmpfs:
      - /tmp:mode=01777
      - /run
      - /var/log/terraform-enterprise
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - type: bind
        source: /var/run/docker.sock
        target: /run/docker.sock
      - type: bind
        source: ./certs
        target: /etc/ssl/private/terraform-enterprise
      - type: volume
        source: terraform-enterprise-cache
        target: /var/cache/tfe-task-worker/terraform
volumes:
  terraform-enterprise-cache:
```


Be sure to double-check and adjust the following values:

**TFE_LICENSE** - your actual FDO license, can be generated on https://license.hashicorp.services/ (more details - https://hashicorp.atlassian.net/wiki/spaces/~638da7e4fde064eda2f1deb3/pages/2711126362/How+to+create+a+test+license+for+FDO+Beta+installation)

**TFE_HOSTNAME** - FQDN; will be visible in Output after you run `terraform apply`

**TFE_DATABASE_HOST** - can be found in `terraform.tfstate` file or in AWS Console (under RDS section)

**TFE_OBJECT_STORAGE_S3_BUCKET** - also can be found in `terraform.tfstate` file or in AWS Console (under S3 section respectively)

## Install TFE

First of all, export the Docker credentials as environmental variables:

```
export TFE_FDO_BETA_USERNAME=hc-support-tfe-beta 
export TFE_FDO_BETA_TOKEN=3gdnBJlYWMvOgnnL0GnEMrff2t5dBmLR4OuMt+Niph+ACRDyGuJE 
```

Then, run the following command to authenticate to container registry:

```
docker login -u $TFE_FDO_BETA_USERNAME -p $TFE_FDO_BETA_TOKEN terraform-enterprise-beta.terraform.io
```


Spin up your Terraform Enterprise container by running:

```
docker compose up --detach
```

Optionally, you can monitor the logs by running the command below in a separate terminal session:

```
docker compose logs --follow
```

Monitor the health of the application until it starts reporting healthy via the command:

```
docker compose exec tfe tfe-health-check-status
```

## Obtain initial user token and create the initial user account


Retrieve your initial admin creation token (IACT) from `https://${TFE_HOSTNAME}/admin/retrieve-iact`

Navigate to `https://${TFE_HOSTNAME}/admin/account/new?token=${IACT_TOKEN}`

Follow the prompts to create your initial admin user:

![Screenshot 2023-09-13 at 14 26 23](https://github.com/dmitryuchuvatov/fdo-es-docker/assets/119931089/26c0b6d6-e1b7-43f7-9d62-0ab1c6664e30)

Now you are ready to create a new Organization, Workspace and run workloads on your Terraform Enterprise Flexible Deployment Options!
