variable "profile" {
  type    = string
  default = "default"
}

variable "region-master" {
  type    = string
  default = "us-east-2"
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}
