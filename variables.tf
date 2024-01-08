variable "region" {
  type        = string
  description = "The region to deploy resources in"
}

variable "environment_name" {
  type        = string
  description = "Name used to create and tag resources"
}

variable "vpc_cidr" {
  type        = string
  description = "The IP range for the VPC in CIDR format"
}

variable "instance_type" {
  description = "The instance type to use for the TFE host"
  type        = string
  default     = "m5.xlarge"
}

variable "route53_zone" {
  description = "The domain used in the URL"
  type        = string
}

variable "route53_subdomain" {
  description = "The subdomain of the URL"
  type        = string
}

variable "postgresql_user" {
  description = "PostgreSQL user"
  type        = string
}

variable "postgresql_password" {
  description = "PostgreSQL password"
  type        = string
}

variable "database_name" {
  description = "PostgreSQL DB name"
  type        = string
}

variable "cert_email" {
  description = "Email address used to obtain SSL certificate"
  type        = string
}

variable "tfe_release" {
  description = "TFE release"
  type        = string
}

variable "tfe_license" {
  description = "TFE license"
  type        = string
}

variable "tfe_password" {
  description = "TFE password"
  type        = string
}