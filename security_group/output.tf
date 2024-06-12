output "aws_security_group_private" {
  value = aws_security_group.private_sg.id
}

output "aws_security_group2" {
  value = aws_security_group.bastion_sg.id
}

output "awslbsg" {
  value = aws_security_group.lbsg.id
}