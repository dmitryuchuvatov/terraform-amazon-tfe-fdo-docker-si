# tfe_fdo_external_services_aws.py

from diagrams import Cluster, Diagram
from diagrams.aws.general import Client
from diagrams.aws.network import Route53
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDSPostgresqlInstance
from diagrams.aws.storage import SimpleStorageServiceS3Bucket


with Diagram("TFE FDO External Services on AWS", show=False, direction="TB"):
    
    client = Client("Client")
    
    with Cluster("AWS"):
        dns = Route53("DNS")
        with Cluster("VPC"):
            with Cluster("Public Subnet"):
                tfe_instance = EC2("TFE instance")
            
            with Cluster("Private Subnet"):
                postgres = RDSPostgresqlInstance("PostgresSQL")

        s3bucket = SimpleStorageServiceS3Bucket("S3 bucket")

    client >> dns
    dns >> tfe_instance
    tfe_instance >> postgres
    tfe_instance >> s3bucket