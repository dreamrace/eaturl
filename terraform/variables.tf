variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "number_of_zone" {
  type    = number
  default = 2
}

variable "prefix" {
  type    = string
  default = "alpha"
}

variable "host_zone" {
  type = string
  # default = "base.blackcastle.pw"
}

variable "sub_domain" {
  type = string
  # default = "happy"
}

variable "acm_id" {
  type = string
  # default = "arn:aws:acm:ap-southeast-1:xxxxxxx:certificate/xxxxxxxxx"
}

variable "ami" {
  type = string
  # default = "ami-xxxxxxxx"
}
