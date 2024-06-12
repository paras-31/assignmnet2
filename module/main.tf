module "vpc" {
  source = "../vpc"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  azs = [ "ap-south-1a", "ap-south-1b"]
}

module "security_groups" {
  source = "../security_group"
  vpcid = module.vpc.aws_vpc
}

module "NACL" {
  source = "../NACL"
  vpc_id = module.vpc.aws_vpc
  private_subnet = module.vpc.aws_subnet_private[0]
}

module "ec2" {
  source = "../ec2"
  private-subnet = module.vpc.aws_subnet_private[0]
  public-subnet = module.vpc.aws_subnet_public[0]
  public_sg = module.security_groups.aws_security_group2
  private_sg = module.security_groups.aws_security_group_private
}

module "ALB" {
  source = "../ALB"
  vpc_id = module.vpc.aws_vpc
  instance_id = module.ec2.ec2id
  lbsg = module.security_groups.awslbsg
  depends_on = [ module.vpc ]
  public_subnet = module.vpc.aws_subnet_public
}