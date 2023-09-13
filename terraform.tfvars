region                  = "eu-west-2"                      # AWS region to deploy in
environment_name        = "dmitry-fdo-es"                  # Name of the environment, used in naming of resources
vpc_cidr                = "10.200.0.0/16"                  # The IP range for the VPC
route53_zone            = "tf-support.hashicorpdemo.com"   # The domain of your hosted zone in Route 53
route53_subdomain       = "dmitry-fdo-es"                  # The subomain of the URL
postgresql_password     = "Password1#"                     # Password used for the admin user postgres