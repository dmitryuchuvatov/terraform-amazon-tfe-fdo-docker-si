# Provider
terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "2.11.1"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "4.41.0"
    }
  }
}
provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "aws" {
  region = var.region
}