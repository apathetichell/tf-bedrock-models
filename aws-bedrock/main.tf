# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


provider "aws" {
  region = var.aws_region
}

##dynamically retrieve the aws account_id


data "aws_caller_identity" "current" {}


/*resource "aws_s3_bucket" "snowflake_storage_bucket" {
  bucket = var.s3_bucketname

  tags = {
    Name        = var.s3_bucketname_tag
    Environment = var.s3_bucketname_env
  }
}*/


resource "aws_iam_policy" "bedrock-invoke-policy" {
  name = var.bedrock_invoke_policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["bedrock:InvokeModel"]
        Effect   = "Allow"
        Resource = "arn:aws:bedrock:*::foundation-model/*"
      }
    ]
  })

}

resource "aws_iam_policy" "retrieves_schema_policy" {
  name = var.bedrock_retrieve_schema_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = ""arn:aws:s3:::bedrockreinvent/agent_aws_openapi.json""
      }
    ]
  })

}



resource "aws_iam_role" "bedrock-role" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Condition = {StringEquals: {"sts:ExternalId": "${var.external_id}"}} //need to update tof agent
      Effect    = "Allow"
      Principal = {
        AWS = "${var.storage_integration_arn}" //need to upate for agent
    }
      }
    ]
    Version = "2012-10-17"
  })
  description           = null
  force_detach_policies = false
  managed_policy_arns   = [aws_iam_policy.retrieves_schema_policy.arn, aws_iam_policy.bedrock_invoke_policy.arn]
  max_session_duration  = 3600
  name                  = var.bedrock_role //AmazonBedrockExecutionRoleForAgents_workshop
  name_prefix           = null
  path                  = "/"
  permissions_boundary  = null
  tags                  = {}
  tags_all              = {}

}

