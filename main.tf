# VPC
resource "aws_vpc" "tfe" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.environment_name}-vpc"
  }
}

# Public Subnet #1
resource "aws_subnet" "tfe_public" {
  vpc_id     = aws_vpc.tfe.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 0)
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.environment_name}-subnet-public"
  }
}

# Public Subnet #2
resource "aws_subnet" "tfe_public2" {
  vpc_id     = aws_vpc.tfe.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone = "${var.region}c"

  tags = {
    Name = "${var.environment_name}-subnet-public2"
  }
}

# Private Subnet #1
resource "aws_subnet" "tfe_private" {
  vpc_id            = aws_vpc.tfe.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 10)
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.environment_name}-subnet-private"
  }
}

# Private Subnet #2
resource "aws_subnet" "tfe_private2" {
  vpc_id            = aws_vpc.tfe.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 11)
  availability_zone = "${var.region}c"

  tags = {
    Name = "${var.environment_name}-subnet-private2"
  }
}

# IGW (Internet Gateway)
resource "aws_internet_gateway" "tfe_igw" {
  vpc_id = aws_vpc.tfe.id

  tags = {
    Name = "${var.environment_name}-igw"
  }
}

# Link IGW with default VPC Route Table
resource "aws_default_route_table" "tfe" {
  default_route_table_id = aws_vpc.tfe.default_route_table_id

  route {
    cidr_block = local.all_ips
    gateway_id = aws_internet_gateway.tfe_igw.id
  }

  tags = {
    Name = "${var.environment_name}-rtb"
  }
}

# Key Pair
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tfe" {
  key_name   = "${var.environment_name}-keypair"
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

resource "local_file" "tfesshkey" {
  content         = tls_private_key.rsa-4096.private_key_pem
  filename        = "${path.module}/tfesshkey.pem"
  file_permission = "0600"
}

# Security Group
resource "aws_security_group" "tfe_sg" {
  name   = "${var.environment_name}-sg"
  vpc_id = aws_vpc.tfe.id

  tags = {
    Name = "${var.environment_name}-sg"
  }
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.tfe_sg.id

  from_port   = var.ssh_port
  to_port     = var.ssh_port
  protocol    = local.tcp_protocol
  cidr_blocks = [local.all_ips]
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.tfe_sg.id

  from_port   = var.http_port
  to_port     = var.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = [local.all_ips]
}

resource "aws_security_group_rule" "allow_https_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.tfe_sg.id

  from_port   = var.https_port
  to_port     = var.https_port
  protocol    = local.tcp_protocol
  cidr_blocks = [local.all_ips]
}

resource "aws_security_group_rule" "allow_postgresql_inbound_vpc" {
  type              = "ingress"
  security_group_id = aws_security_group.tfe_sg.id

  from_port   = var.postgresql_port
  to_port     = var.postgresql_port
  protocol    = local.tcp_protocol
  cidr_blocks = [aws_vpc.tfe.cidr_block]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.tfe_sg.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = [local.all_ips]
}

# EC2
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "tfe" {
  ami                    = data.aws_ami.ubuntu.image_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.tfe.key_name
  vpc_security_group_ids = [aws_security_group.tfe_sg.id]
  subnet_id              = aws_subnet.tfe_public.id
  iam_instance_profile   = aws_iam_instance_profile.tfe_profile.name

  user_data = "${file("install_docker.sh")}"
  
  root_block_device {
    volume_size = 50
  }

  tags = {
    Name = "${var.environment_name}-ec2"
  }
}

# Public IP
resource "aws_eip" "eip_tfe" {
  vpc = true
  tags = {
    Name = "${var.environment_name}-eip"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.tfe.id
  allocation_id = aws_eip.eip_tfe.id
}

# DNS
data "aws_route53_zone" "selected" {
  name         = var.route53_zone
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.fqdn
  type    = "A"
  ttl     = "300"
  records = [aws_eip.eip_tfe.public_ip]
}

# S3 bucket
resource "aws_s3_bucket" "tfe_files" {
  bucket = "${var.environment_name}-bucket"

  tags = {
    Name = "${var.environment_name}-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "tfe_files" {
  bucket = aws_s3_bucket.tfe_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM
resource "aws_iam_instance_profile" "tfe_profile" {
  name = "${var.environment_name}-profile"
  role = aws_iam_role.tfe_s3_role.name
}

resource "aws_iam_role" "tfe_s3_role" {
  name = "${var.environment_name}-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    tag-key = "${var.environment_name}-role"
  }
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.tfe_s3_role.name
}

# RDS
resource "aws_db_instance" "tfe" {
  identifier          = "${var.environment_name}-postgres"
  allocated_storage   = 50
  db_name             = "fdo"
  engine              = "postgres"
  engine_version      = "14.5"
  instance_class      = "db.m5.large"
  username            = "postgres"
  password            = var.postgresql_password
  skip_final_snapshot = true

  multi_az               = false
  vpc_security_group_ids = [aws_security_group.tfe_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.tfe.name

  tags = {
    Name = "${var.environment_name}-postgres"
  }
}

resource "aws_db_subnet_group" "tfe" {
  name       = "${var.environment_name}-subnetgroup"
  subnet_ids = [aws_subnet.tfe_private.id, aws_subnet.tfe_private2.id]

  tags = {
    Name = "${var.environment_name}-subnetgroup"
  }
}