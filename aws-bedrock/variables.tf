# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Input variable definitions


variable "bedrock_invoke_policy_name" {
  type=string
}


variable "bedrock_retrieve_schema_name" {
  type=string
}

variable "bedrock_role" {
  type=string
  default="AmazonBedrockExecutionRoleForAgents_workshop"
}

variable "bedrock_model" {
  type=string
  default="anthropic.claude-3-haiku-20240307-v1:0"
}

variable "agent_name"{
  type=string
}

variable "agent_instruction" {
  type=string
}

variable "ecr_name" {
  type=string
}