variable "region" {
  default = "us-east-1"
}

variable "bucket" {}
variable "lambda_transformation" {
}
variable "lambda_filename" {}
variable "file_location" {}
variable "lambda_handler" {}
variable "kinesis_prefix" {}
variable "kinesis_error_output_prefix" {}
#variable "s3_location" {}
variable "buffer_interval" {}
variable "buffer_size" {}
variable "compression_format" {}
variable "runtime" {}
variable "timeout" {}
