variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string

}

variable "availability_zones" {
  description = "A list of availability zones for the VPC"
  type        = list(string)

}