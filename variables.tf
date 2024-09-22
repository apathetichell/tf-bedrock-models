# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Input variable definitions

variable "aws_region" {
  description = "default aws region"
  default= "us-west-2"
  type        = string
}

variable "s3_bucketname" {
  description = "bucket to integration with snowflake"
  default= "snowflake-s3-bucket1-test-terraform"
  type        = string
}

variable "s3_bucketname_tag" {
  description = "description of bucket to integrate with snowflake"
  default= "snowflake-s3-bucket1-test-terraform"
  type        = string
}

variable "s3_bucketname_env" {
  description = "tag for bucket to integration with snowflake"
  default= "DEV"
  type        = string
}

variable "snowflakeRole" {
  description = "role for integrating with snowflake"
  default= "Snowflake_S3_integration_role"
  type        = string
}

variable "snowflakes3policyname" {
  description = "policy for integrating with snowflake"
  default= "Snowflake_S3_integration_policy"
  type        = string
}


variable "snowflakeS3StorageIntegration" {
  description = "policy for integrating with snowflake"
  default= "S3_Storage"
  type        = string
}




