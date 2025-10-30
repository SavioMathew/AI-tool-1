provider "aws" {
  region = var.region
}

resource "aws_security_group" "ssh-sg" {
  name        = "ssh-sg"
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

resource "aws_instance" "ec2" {
  ami                    = "ami-03aa99ddf5498ceb9"
  instance_type          = "t2.micro"
  key_name               = "cron"
  vpc_security_group_ids = [aws_security_group.ssh-sg.id]
  user_data              = templatefile("${path.module}/user_data.sh.tpl", {
    username   = var.username
    app_dir    = var.app_dir
  })

  tags = {
    Name = "tf-ec2-${var.username}"
  }
}
