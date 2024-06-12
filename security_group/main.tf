# Security Groups
resource "aws_security_group" "bastion_sg" {
  name        = var.sgname
  description = var.description
  vpc_id      = var.vpcid

  dynamic "ingress" {
    for_each = ["80","22","65535"]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["10.0.1.0/24"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "bastion_sg"
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Allow internal traffic"
  vpc_id      = var.vpcid

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "private_sg"
  }
}


resource "aws_security_group" "lbsg" {
  name        = "lbsg"
  description = "Allow internal traffic"
  vpc_id      = var.vpcid

  ingress {
    from_port   = 0
    to_port     = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "lbsg"
  }
}