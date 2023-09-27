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
Apply complete! Resources: 34 added, 0 changed, 0 destroyed.

Outputs:

ssh_login = "ssh -i tfesshkey.pem ubuntu@dmitry-fdo-test.tf-support.hashicorpdemo.com"
tfe_hostname = "https://dmitry-fdo-test.tf-support.hashicorpdemo.com"
```

# Installing TFE FDO Beta

## SSH into the new instance

Copy the SSH login command from the above-mentioned Output, paste it into the Terminal and hit Enter. Type Y and hit Enter again.

```
ssh -i tfesshkey.pem ubuntu@dmitry-fdo-es.tf-support.hashicorpdemo.com
```
## Prepare YAML file

In this example, we will install Terraform Enterprise in External Services mode.

Create a `compose.yaml` file in `fdo` directory and populate it with your desired deployment configuration:

```
---
name: terraform-enterprise
services:
  tfe:
    image: images.releases.hashicorp.com/hashicorp/terraform-enterprise:v202309-1
    environment:
      TFE_LICENSE: "02MV4UU43BK5HGYYTOJZWFQMTMNNEWU33JLFVE252ZK5HG2TKEKF2E4RCONRHUGMBVJVDVCM2MKRVTCT2EM52FS2SJPJGTEVTMJV5FSNCNNVHG2SLJO5UVSM2WPJSEOOLULJMEUZTBK5IWST3JJJWE2VCNGJHFOTTKJVUTC2C2NJWGWTCUJE2U4VCBORGUITJVJVUTC3C2NJMTETTNKEYFSVCNO5MXUQLJJRBUU4DCNZHDAWKXPBZVSWCSOBRDENLGMFLVC2KPNFEXCSLJO5UWCWCOPJSFOVTGMRDWY5C2KNETMSLKJF3U22SNORGUI23UJVKEUVKNIRTTMTLKLE3E4VCBOVGWURLYJVKFCMKOIRRXSV3JJFZUS3SOGBMVQSRQLAZVE4DCK5KWST3JJF4U2RCJPJGFIQJVJRKEK6KWIRAXOT3KIF3U62SBO5LWSSLTJFWVMNDDI5WHSWKYKJYGEMRVMZSEO3DULJJUSNSJNJEXOTLKKV2E2RCFORGUIRSVJVCECNSNIRATMTKEIJQUS2LXNFSEOVTZMJLWY5KZLBJHAYRSGVTGIR3MORNFGSJWJFVES52NNJKXITKEIV2E2RCGKVGUIQJWJVCECNSNIRBGCSLJO5UWGSCKOZNEQVTKMRBUSNSJNZJGYY3OJJUFU3JZPFRFGSLTJFWVU42ZK5SHUSLKOA3WMWBQHUXGCQ3SM5MXA32VPB3GQTTJJJYFU2ZSKVMDO5DMKZBWOOJUIUVUCSRSJYYHU4LMOVSWS3LRPFLDIVDPF5EES3CFNYXUWTTFMR4WW4ZQNFEDCUSEGJVWMTKOMMYE4YJQINVXUSKEI5BDKMLEIFVWGYJUMRLDAMZTHBIHO3KWNRQXMSSQGRYEU6CJJE4UINSVIZGFKYKWKBVGWV2KORRUINTQMFWDM32PMZDW4SZSPJIEWSSSNVDUQVRTMVNHO4KGMUVW6N3LF5ZSWQKUJZUFAWTHKMXUWVSZM4XUWK3MI5IHOTBXNJBHQSJXI5HWC2ZWKVQWSYKIN5SWWMCSKRXTOMSEKE6T2"
      TFE_HOSTNAME: dmitry-fdo-test.tf-support.hashicorpdemo.com
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
      TFE_DATABASE_HOST: "dmitry-fdo-test-postgres.cheg1b8bnf4j.eu-west-2.rds.amazonaws.com"
      TFE_DATABASE_NAME: "fdo"
      TFE_DATABASE_PARAMETERS: "sslmode=disable"

      # Object storage settings
      TFE_OBJECT_STORAGE_TYPE: "s3"
      TFE_OBJECT_STORAGE_S3_REGION: "eu-west-2"
      TFE_OBJECT_STORAGE_S3_BUCKET: "dmitry-fdo-test-bucket"
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

**TFE_LICENSE** - your actual FDO license from https://license.hashicorp.services/

**TFE_HOSTNAME** - FQDN; will be visible in Output after you run `terraform apply`

**TFE_DATABASE_HOST** - can be found in `terraform.tfstate` file or in AWS Console (under RDS section)

**TFE_OBJECT_STORAGE_S3_BUCKET** - also can be found in `terraform.tfstate` file or in AWS Console (under S3 section respectively)

## Install TFE

Change the directory to FDO and run the following command:

```
cd /fdo/
sudo bash
```

Log in to the Terraform Enterprise container image registry:

```
cat /fdo/terraform.hclic | docker login --username terraform images.releases.hashicorp.com --password-stdin
```
 
Pull the Terraform Enterprise image from the registry:

```
docker pull images.releases.hashicorp.com/hashicorp/terraform-enterprise:v202309-1
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
