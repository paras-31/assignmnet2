resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.module}/private_key.pem"
}


resource "aws_key_pair" "generated_key" {
  key_name   = "generated-key2"
  public_key = tls_private_key.example.public_key_openssh
}


resource "aws_instance" "webprivateinst" {
  ami           = "ami-0e1d06225679bc1c5"  # Update with your desired AMI for the DB instance
  instance_type = "t2.micro"               # Update with your desired instance type
  subnet_id     = var.private-subnet
  security_groups = [var.private_sg]
#   key_name = aws_key_pair.generated_key.key_name
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd 
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "web-private-Instance"
  }
}

resource "aws_instance" "db_instanceprivate" {
  ami           = "ami-0e1d06225679bc1c5"  # Update with your desired AMI for the DB instance
  instance_type = "t2.micro"               # Update with your desired instance type
  subnet_id     = var.private-subnet
  security_groups = [var.private_sg]
#   key_name = aws_key_pair.generated_key.key_name
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y postgresql postgresql-contrib
              sudo -u postgres psql -c "CREATE USER appuser WITH PASSWORD 'password';"
              sudo -u postgres psql -c "CREATE DATABASE appdb OWNER appuser;"
              sudo -u postgres psql -c "ALTER ROLE appuser SET client_encoding TO 'utf8';"
              sudo -u postgres psql -c "ALTER ROLE appuser SET default_transaction_isolation TO 'read committed';"
              sudo -u postgres psql -c "ALTER ROLE appuser SET timezone TO 'UTC';"
              systemctl restart postgresql
              EOF


  tags = {
    Name = "db-private-Instance"
  }
}


resource "aws_instance" "bastionisntance" {
  ami                         = "ami-0e1d06225679bc1c5"  # Update with your desired AMI for the web instance
  instance_type               = "t2.micro"              # Update with your desired instance type
  subnet_id                   = var.public-subnet
  associate_public_ip_address = true
  security_groups             = [var.public_sg]

  tags = {
    Name = "Bastion-Instance"
  }
}

