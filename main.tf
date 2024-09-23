# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Input variable definitio


module "set_up_bedrock_agent" {
  source = "./aws-bedrock"

bedrock_invoke_policy_name="Bedrock-InvokeModel-Policy"


bedrock_retrieve_schema_name="retrieve_bedrock_schema"

bedrock_role="AmazonBedrockExecutionRoleForAgents_workshop"

bedrock_model="anthropic.claude-3-haiku-20240307-v1:0" //anthropic.claude-3-haiku-20240307-v1"

agent_name="Agent-AWS_bedrock_claude_haiku_terraform_test"

agent_instruction="You are an expert AWS Certified Solutions Architect. Your role is to help customers understand best practices on building on AWS"

ecr_name="agent_ecr_bedrock"

lambda_function_name="bedrock-lambda-test"

lambda_invoke_policy_name="lambda-invoke-policy"

 }


