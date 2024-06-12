# DevOps Practical Task: Secure Private Network Setup on AWS

This repository contains Terraform configuration files, application setup scripts, and documentation for setting up a secure private network on AWS using VPC, provisioning two EC2 instances for a web application and a PostgreSQL database, and configuring secure communication between them.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Architecture](#architecture)
3. [Setup Instructions](#setup-instructions)
   - [1. Set Up a Private Network](#1-set-up-a-private-network)
   - [2. Provision Remote Machines](#2-provision-remote-machines)
   - [3. Application and Database Configuration](#3-application-and-database-configuration)
   - [4. Secure Communication](#4-secure-communication)
   - [5. Automate the Setup](#5-automate-the-setup)
4. [Cleanup](#cleanup)
5. [Troubleshooting](#troubleshooting)

## Prerequisites

- AWS account with administrative access.
- AWS CLI installed and configured.
- Terraform installed.
- SSH key pair for accessing EC2 instances.
- Basic knowledge of AWS services and Terraform.

## Architecture

- AWS VPC with private and public subnets.
- Two EC2 instances in the private subnet:
  - Web application instance (Node.js or Python Flask).
  - PostgreSQL database instance.
- Bastion host in the public subnet for secure SSH access.
- Application Load Balancer (ALB) for routing web traffic.
- Security groups and network ACLs for traffic control.

## Setup Instructions

### 1. Set Up a Private Network

1. **Create a VPC:**
   - VPC with CIDR block `10.0.0.0/16`.
2. **Create Subnets:**
   - Public subnet with CIDR block `10.0.1.0/24`.
   - Private subnet with CIDR block `10.0.2.0/24`.
3. **Configure Routing Tables:**
   - Public route table with route to the internet gateway.
   - Private route table without internet access.

### 2. Provision Remote Machines

1. **Launch EC2 Instances:**
   - Web application instance in the private subnet.
   - PostgreSQL database instance in the private subnet.
2. **Security Groups:**
   - Allow necessary traffic between web and database instances.
   - Allow SSH access to bastion host from a specific IP.

### 3. Application and Database Configuration

1. **Web Application Setup:**
   - Install Node.js or Python Flask on the web instance.
   - Deploy the application.
2. **PostgreSQL Setup:**
   - Install PostgreSQL on the database instance.
   - Configure database for the application.

### 4. Secure Communication

1. **Security Groups and Network ACLs:**
   - Define security groups to control traffic.
   - Configure network ACLs for additional security.
2. **Bastion Host:**
   - Set up a bastion host in the public subnet.
   - Configure SSH access to private instances through the bastion host.

### 5. Automate the Setup

1. **Terraform Configuration:**
   - Use Terraform scripts to automate VPC, subnets, security groups, and EC2 instances setup.
   - Ensure scripts are modular and well-documented.

## Cleanup

1. **Remove Resources:**
   - Use Terraform to destroy created resources.
   - Ensure no resources are left behind.

## Troubleshooting

- Verify AWS CLI configuration.
- Check Terraform logs for errors.
- Ensure SSH key pair permissions are correct.
- Validate security group rules and network ACLs.

## Terraform Configuration Files

### main.tf

```hcl
provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"  # Replace with your preferred AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "WebInstance"
  }
}

resource "aws_instance" "db" {
  ami           = "ami-0abcdef1234567890"  # Replace with your preferred AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.db_sg.name]

  tags = {
    Name = "DBInstance"
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-0abcdef1234567890"  # Replace with your preferred AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "BastionInstance"
  }
}

output "web_instance_ip" {
  value = aws_instance.web.public_ip
}

output "db_instance_ip" {
  value = aws_instance.db.private_ip
}

output "bastion_instance_ip" {
  value = aws_instance.bastion.public_ip
}
