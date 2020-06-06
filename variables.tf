variable "application_name" {
  type = string
}

variable "env" {
  type = string
}

variable "external_port" {
  type    = number
  default = 443
}


variable "internal_port" {
  type    = number
  default = 80
}

variable "tags" {
  type = map(string)
}

variable "task_definition_arn" {
  type = string
}

variable "scaling_min" {
  default = 2
  type    = number
}

variable "scaling_max" {
  default = 10
  type    = number
}

variable "scaling_desired" {
  default = 2
  type    = number
}

variable "health_endpoint" {
  default = "/health"
}

variable "artifact_bucket" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "service_subnet_ids" {
  type = list(string)
}

variable "alb_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {}

variable "cert_arn" {
  type = string
}
