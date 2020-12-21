variable "AWS_REGION" {
    default = "us-east-2"
}

variable "IMAGE_ID" {
    default = "ami-0c55b159cbfafe1f0"
}

variable "SERVER_PORT" {
  type        = number
  default     = 8080
}

data "aws_availability_zones" "all" {}
