provider "aws" {
  region = var.region
}

# ✅ Try to fetch existing SG (don't fail if not found)
data "aws_security_group" "existing" {
  filter {
    name   = "group-name"
    values = ["ssh-1-sg"]
  }

  lifecycle {
    ignore_errors = true
  }
}

# ✅ Create SG only if not exists
resource "aws_security_group" "ssh" {
  count       = length(data.aws_security_group.existing.*.id) == 0 ? 1 : 0
  name        = "ssh-1-sg"
  description = "Allow SSH inbound"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ Decide SG ID (existing or newly created)
locals {
  ssh_sg_id = length(data.aws_security_group.existing.*.id) > 0 ?
    data.aws_security_group.existing.id :
    aws_security_group.ssh[0].id
}

# ✅ EC2 instance
resource "aws_instance" "ec2" {
  ami           = "ami-03aa99ddf5498ceb9"
  instance_type = "t2.micro"
  key_name      = "cron"

  vpc_security_group_ids = [local.ssh_sg_id]

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    username = var.username
    app_dir  = var.app_dir
  })

  tags = {
    Name = "tf-ec2-${var.username}"
  }
}
