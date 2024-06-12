variable "vpcid" {
  type = string
}

variable "description" {
  type = string
  default = "Allow SSH inbound traffic"
}

variable "sgname" {
  type = string
  default = "bastion_sg"
}

