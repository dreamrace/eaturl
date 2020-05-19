variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "Region this stack resides in"
}

variable "access_key" {
  type        = string
  description = "Access key for amazon services"
}

variable "secret_key" {
  type        = string
  description = "Secret key for amazon services"
}

variable "number_of_zone" {
  type        = number
  default     = 2
  description = "Number of az does the deployment span"
}

variable "prefix" {
  type        = string
  default     = "alpha"
  description = "Prefix for resources deployed"
}

variable "host_zone" {
  type = string
  # default = "base.blackcastle.pw"
  description = "Host zone dns record"
}

variable "sub_domain" {
  type = string
  # default = "happy"
  description = "sub domain for dns record"
}

variable "acm_id" {
  type = string
  # default = "arn:aws:acm:ap-southeast-1:xxxxxxx:certificate/xxxxxxxxx"
  description = "arn for acm certificate"
}

variable "ami" {
  type = string
  # default = "ami-xxxxxxxx"
  description = "AMI for image generated with packer"
}
