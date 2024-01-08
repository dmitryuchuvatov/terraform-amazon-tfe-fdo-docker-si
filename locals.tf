locals {
  all_ips = "0.0.0.0/0"
  fqdn    = "${var.route53_subdomain}.${var.route53_zone}"
}