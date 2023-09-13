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

variable "ssh_port" {
  description = "Server port for SSH requests"
  type        = number
  default     = 22
}

variable "http_port" {
  description = "Server port for HTTPS requests"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "Server port for HTTPS requests"
  type        = number
  default     = 443
}

variable "postgresql_port" {
  description = "PostgreSQL database port"
  type        = number
  default     = 5432
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

variable "postgresql_password" {
  description = "PostgreSQL password"
  type        = string
}