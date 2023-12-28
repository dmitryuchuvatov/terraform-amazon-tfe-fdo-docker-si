output "tfe_hostname" {
  description = "URL for accessing TFE"
  value       = "https://${local.fqdn}"
}

output "ssh_login" {
  description = "SSH login command"
  value       = "ssh -i tfesshkey.pem ubuntu@${local.fqdn}"
}




