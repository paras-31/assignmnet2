resource "aws_network_acl" "private_acl" {
  vpc_id = var.vpc_id
  tags = {
    Name = "private_acl"
  }
}

resource "aws_network_acl_rule" "inbound_rule" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.1.0/24"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "outbound_rule" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

# Adding PostgreSQL inbound rule
resource "aws_network_acl_rule" "inbound_postgresql_rule" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.1.0/24"
  from_port      = 5432
  to_port        = 5432
}

# Adding PostgreSQL outbound rule
resource "aws_network_acl_rule" "outbound_postgresql_rule" {
  network_acl_id = aws_network_acl.private_acl.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 5432
  to_port        = 5432
}

resource "aws_network_acl_association" "private_acl_assoc" {
  subnet_id       = var.private_subnet
  network_acl_id  = aws_network_acl.private_acl.id
}
