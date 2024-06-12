variable "instance_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "lbsg" {
  type = string
}

variable "public_subnet" {
  type = list(any)
}