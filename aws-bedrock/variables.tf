# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Input variable definitions


variable "bedrock_invoke_policy_name" {
  type=string
}


variable "bedrock_retrieve_schema_name" {
  type=string
}

variable "bedrock_role" 
{
  type=string
  default="AmazonBedrockExecutionRoleForAgents_workshop"
}