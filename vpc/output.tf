output "aws_vpc" {
  value = aws_vpc.main.id
}

output "aws_subnet_public" {
  value = aws_subnet.public_subnets[*].id
}

output "aws_subnet_private" {
  value = aws_subnet.private_subnets[*].id
}

output "cidr_block" {
  value = aws_vpc.main.cidr_block
}