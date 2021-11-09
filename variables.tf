
variable lambda_function_name {
  type = string
  default = "auth"
}

variable lambda_handler {
  type    = string
  default = "handler.app"
}

variable lambda_runtime {
  type    = string
  default = "nodejs14.x"
}


variable "accesskey" {
  type = string
  default = ""
}

variable "secretkey" {
  type = string
  default = ""
}


variable "region" {
  type = string
  default = "us-east-1"
}
